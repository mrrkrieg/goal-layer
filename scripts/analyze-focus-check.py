#!/usr/bin/env python3
"""Analyze the opt-in synthetic M1 focus reports without running native UI."""

import argparse
import json
import math
import sys
from pathlib import Path


EXPECTED_CHARACTERS = 6000
EXPECTED_SELECTION = 3000
FIXTURE_UNIT = "abcdefghij0123456789"


def integer(value):
    return type(value) is int and value >= 0


def timestamp(value):
    try:
        return type(value) in (int, float) and math.isfinite(value) and value > 0
    except OverflowError:
        return False


def analyze(pulses, probe):
    """Return checks of recorded measurements; missing evidence never passes."""
    checks = []

    def check(name, passed, observed, required):
        checks.append({"check": name, "passed": bool(passed),
                       "observed": observed, "required": required})

    check("pulse_schema", pulses.get("schema") == "native-focus-pulses-v1",
          pulses.get("schema"), "native-focus-pulses-v1")
    check("probe_schema", probe.get("schema") == "synthetic-focus-probe-v2",
          probe.get("schema"), "synthetic-focus-probe-v2 with all-callback counters")
    check("probe_identity", probe.get("own_bundle_identifier") == "org.goallayer.focus-probe",
          probe.get("own_bundle_identifier"), "org.goallayer.focus-probe")
    check("fixture_identity", probe.get("fixture_unit") == FIXTURE_UNIT,
          probe.get("fixture_unit"), FIXTURE_UNIT)

    raw_pulses = pulses.get("samples")
    pulse_rows = raw_pulses if isinstance(raw_pulses, list) else []
    pulse_objects = [row for row in pulse_rows if isinstance(row, dict)]
    check("exactly_100_updates",
          len(pulse_rows) == 100 and len(pulse_objects) == 100
          and type(pulses.get("count")) is int and pulses["count"] == 100
          and [row.get("index") for row in pulse_objects] == list(range(1, 101))
          and all(type(row.get("index")) is int for row in pulse_objects),
          {"reported_count": pulses.get("count"), "sample_count": len(pulse_rows)},
          "100 sample objects, count 100, indexes 1 through 100 exactly once in order")

    started, ended = pulses.get("started_at"), pulses.get("ended_at")
    interval_valid = timestamp(started) and timestamp(ended) and ended > started
    pulse_times = [row.get("timestamp") for row in pulse_objects]
    pulse_times_valid = bool(pulse_times) and all(timestamp(t) for t in pulse_times)
    check("pulse_timestamps",
          interval_valid and pulse_times_valid and pulse_times == sorted(pulse_times)
          and all(started <= t <= ended for t in pulse_times),
          {"started_at": started, "ended_at": ended},
          "finite ordered timestamps inside a positive recorded pulse interval")

    def inside(row):
        value = row.get("timestamp")
        return interval_valid and timestamp(value) and started <= value <= ended

    for field, counter, name in [
        ("panel_key", "key_violations", "zero_panel_key_samples"),
        ("app_active", "activation_violations", "zero_app_activation_samples"),
    ]:
        observed = sum(row.get(field) is True for row in pulse_objects)
        aggregate_valid = counter not in pulses or (
            integer(pulses[counter]) and pulses[counter] == observed)
        check(name, bool(pulse_objects) and all(row.get(field) is False for row in pulse_objects)
              and aggregate_valid,
              {"sampled_violations": observed, "reported_violations": pulses.get(counter)},
              "every pulse explicitly false; any reported counter agrees and is zero")

    frontmost_count = sum(row.get("frontmost_is_focus_probe") is True for row in pulse_objects)
    check("focus_probe_frontmost_for_every_update",
          len(pulse_objects) == 100 and frontmost_count == 100,
          frontmost_count, "100 of 100 pulses explicitly frontmost_is_focus_probe true")

    raw_probe = probe.get("samples")
    probe_rows = raw_probe if isinstance(raw_probe, list) else []
    events = [row for row in probe_rows if isinstance(row, dict)]
    event_fields_valid = bool(events) and len(events) == len(probe_rows) and all(
        isinstance(row.get("event"), str) and timestamp(row.get("timestamp"))
        and integer(row.get("character_count"))
        and type(row.get("fixture_prefix_matches")) is bool
        and integer(row.get("selection_location")) and integer(row.get("selection_length"))
        and row["selection_location"] + row["selection_length"] <= row["character_count"]
        for row in events)
    event_times = [row.get("timestamp") for row in events]
    check("probe_sample_fields", event_fields_valid and event_times == sorted(event_times),
          {"sample_count": len(probe_rows)},
          "ordered timestamped event objects with valid character/selection/fixture fields")

    text_events = [row for row in events if row.get("event") == "text"]
    overlap = [row for row in text_events if inside(row)]
    text_total = probe.get("text_event_count")
    check("text_callback_count", integer(text_total) and text_total > 0
          and text_total >= len(text_events),
          {"all_callback_count": text_total, "retained_text_samples": len(text_events)},
          "positive all-callback count at least as large as retained text samples")
    check("timestamped_typing_overlap", bool(overlap),
          {"retained_text_samples_in_interval": len(overlap),
           "first_text_at": overlap[0].get("timestamp") if overlap else None,
           "last_text_at": overlap[-1].get("timestamp") if overlap else None},
          "at least one actual retained text callback timestamp inside the pulse interval")
    focus_samples = sum(not (row.get("window_key") is True and row.get("app_active") is True)
                        for row in overlap)
    focus_total = probe.get("unexpected_text_focus_event_count")
    check("zero_unexpected_text_focus_events", type(focus_total) is int and focus_total == 0
          and bool(overlap) and focus_samples == 0,
          {"all_callback_violations": focus_total,
           "retained_text_in_interval_violations": focus_samples},
          "all-callback focus counter zero; every retained text callback inside interval explicitly window_key/app_active true")

    mismatch_samples = sum(row.get("fixture_prefix_matches") is False for row in events)
    mismatch_total = probe.get("fixture_mismatch_event_count")
    check("zero_fixture_mismatches", type(mismatch_total) is int and mismatch_total == 0
          and mismatch_samples == 0 and probe.get("final_fixture_matches") is True,
          {"all_callback_mismatches": mismatch_total, "retained_mismatches": mismatch_samples,
           "final_fixture_matches": probe.get("final_fixture_matches")},
          "all-callback mismatch counter zero, no retained mismatch, final fixture matches")
    caret_samples = sum(not (integer(row.get("character_count"))
                            and row.get("selection_location") == row.get("character_count")
                            and type(row.get("selection_location")) is int
                            and type(row.get("selection_length")) is int
                            and row.get("selection_length") == 0) for row in text_events)
    caret_total = probe.get("unexpected_text_caret_event_count")
    check("zero_unexpected_text_caret_events", type(caret_total) is int and caret_total == 0
          and caret_samples == 0,
          {"all_callback_violations": caret_total, "retained_text_violations": caret_samples},
          "all-callback caret counter zero; retained text callbacks have zero-length caret at end")
    final = {name: probe.get(name) for name in
             ("final_character_count", "final_selection_location", "final_selection_length")}
    check("exact_final_text_and_caret",
          all(type(value) is int for value in final.values())
          and final == {"final_character_count": EXPECTED_CHARACTERS,
                        "final_selection_location": EXPECTED_CHARACTERS,
                        "final_selection_length": 0},
          final, "exactly 6000 fixture characters and zero-length caret at location 6000")

    selections = [(index, row) for index, row in enumerate(events)
                  if row.get("event") == "selection" and inside(row)
                  and row.get("character_count") == EXPECTED_SELECTION
                  and row.get("selection_location") == 0
                  and row.get("selection_length") == EXPECTED_SELECTION]
    restoration = None
    selection = None
    for index, selected in selections:
        restored = next((row for row in events[index + 1:]
                         if row.get("event") == "selection" and inside(row)
                         and timestamp(selected.get("timestamp"))
                         and row["timestamp"] >= selected["timestamp"]
                         and row.get("character_count") == EXPECTED_SELECTION
                         and row.get("selection_location") == EXPECTED_SELECTION
                         and row.get("selection_length") == 0), None)
        if restored is not None:
            selection, restoration = selected, restored
            break
    check("select_all_and_end_restoration_during_updates", restoration is not None,
          {"select_all_samples_in_interval": len(selections),
           "selection_at": selection.get("timestamp") if selection else None,
           "restoration_at": restoration.get("timestamp") if restoration else None},
          "timestamped selection of all 3000 characters, then explicit end restoration at 3000; both inside interval")

    return {"schema": "native-focus-analysis-v1", "passed": all(c["passed"] for c in checks),
            "checks": checks, "failed_checks": [c["check"] for c in checks if not c["passed"]],
            "probe_sample_method": probe.get("sample_method"),
            "limitations": [
                "Evaluates instrumented measurements; it does not independently verify report provenance or native instrumentation.",
                "Pulse flags are instantaneous samples, not continuous monitoring between updates.",
                "Aggregate counters cover callbacks without assigning timestamps to omitted samples; no hidden callback timing is inferred.",
                "A retained select-all-sized selection is evidence of selection state, not independent proof of a physical shortcut key sequence.",
                "This check does not accept the complete M1 display, fullscreen, accessibility, responsiveness, or hardware gates.",
            ]}


def reject_constant(value):
    raise ValueError("Non-finite JSON number: " + value)


def unique_object(pairs):
    result = {}
    for name, value in pairs:
        if name in result:
            raise ValueError("Duplicate JSON key: " + name)
        result[name] = value
    return result


def load_report(path):
    value = json.loads(path.read_text(), parse_constant=reject_constant,
                       object_pairs_hook=unique_object)
    if not isinstance(value, dict):
        raise ValueError("Report must be a JSON object")
    return value


def run_constructed_tests():
    """Reproduce the original 44 cases plus six narrowly related focus cases."""
    import copy
    import subprocess
    import tempfile

    names = []

    def ensure(condition, message):
        if not condition:
            raise AssertionError(message)

    pulses = {"schema": "native-focus-pulses-v1", "started_at": 100.0, "ended_at": 110.0,
              "count": 100, "key_violations": 0, "activation_violations": 0,
              "samples": [{"index": i, "timestamp": 100 + i * .09, "panel_key": False,
                           "app_active": False, "frontmost_is_focus_probe": True}
                          for i in range(1, 101)]}

    def event(kind, at, count, location=None, length=0):
        return {"event": kind, "timestamp": at, "character_count": count,
                "selection_location": count if location is None else location,
                "selection_length": length, "fixture_prefix_matches": True,
                "window_key": True, "app_active": True, "fullscreen": False}

    probe = {"schema": "synthetic-focus-probe-v2", "own_bundle_identifier": "org.goallayer.focus-probe",
             "fixture_unit": FIXTURE_UNIT, "sample_method": "CONSTRUCTED TEST DATA ONLY",
             "text_event_count": 6000, "fixture_mismatch_event_count": 0,
             "unexpected_text_caret_event_count": 0, "unexpected_text_focus_event_count": 0,
             "final_character_count": 6000, "final_fixture_matches": True,
             "final_selection_location": 6000, "final_selection_length": 0,
             "samples": [event("ready", 99, 0), event("text", 100.2, 20),
                         event("text", 103.8, 3000), event("selection", 104, 3000, 0, 3000),
                         event("selection", 104.1, 3000), event("text", 105, 4000),
                         event("text", 109.9, 6000), event("termination", 111, 6000)]}
    ensure(analyze(pulses, probe)["passed"], "Constructed positive fixture must pass")
    names.append("constructed positive fixture")

    def reject(label, mutate, expected):
        p, q = copy.deepcopy(pulses), copy.deepcopy(probe)
        mutate(p, q)
        result = analyze(p, q)
        ensure(not result["passed"] and expected in result["failed_checks"],
               label + ": " + str(result["failed_checks"]))
        names.append(label)

    reject("99 pulses", lambda p,q: p["samples"].pop(), "exactly_100_updates")
    reject("repeated pulse index", lambda p,q: p["samples"][1].update(index=1), "exactly_100_updates")
    reject("incorrect reported count", lambda p,q: p.update(count=99), "exactly_100_updates")
    reject("boolean reported count", lambda p,q: p.update(count=True), "exactly_100_updates")
    reject("panel stole key status", lambda p,q: p["samples"][5].update(panel_key=True), "zero_panel_key_samples")
    reject("app activated", lambda p,q: p["samples"][5].update(app_active=True), "zero_app_activation_samples")
    reject("false frontmost", lambda p,q: p["samples"][5].update(frontmost_is_focus_probe=False), "focus_probe_frontmost_for_every_update")
    reject("missing frontmost", lambda p,q: p["samples"][5].pop("frontmost_is_focus_probe"), "focus_probe_frontmost_for_every_update")
    reject("missing key flag", lambda p,q: p["samples"][5].pop("panel_key"), "zero_panel_key_samples")
    reject("aggregate contradiction", lambda p,q: p.update(key_violations=1), "zero_panel_key_samples")
    reject("pulse outside interval", lambda p,q: p["samples"][-1].update(timestamp=111), "pulse_timestamps")
    reject("reversed pulse interval", lambda p,q: p.update(ended_at=99), "pulse_timestamps")
    reject("unordered pulse times", lambda p,q: p["samples"][3].update(timestamp=100.01), "pulse_timestamps")
    reject("legacy no aggregate coverage", lambda p,q: q.update(schema="synthetic-focus-probe-v1"), "probe_schema")
    reject("missing mismatch aggregate", lambda p,q: q.pop("fixture_mismatch_event_count"), "zero_fixture_mismatches")
    reject("hidden mismatch caught by aggregate", lambda p,q: q.update(fixture_mismatch_event_count=1), "zero_fixture_mismatches")
    reject("retained mismatch contradicts aggregate", lambda p,q: q["samples"][1].update(fixture_prefix_matches=False), "zero_fixture_mismatches")
    reject("hidden caret event caught by aggregate", lambda p,q: q.update(unexpected_text_caret_event_count=1), "zero_unexpected_text_caret_events")
    reject("retained text caret event", lambda p,q: q["samples"][1].update(selection_location=0), "zero_unexpected_text_caret_events")
    reject("wrong final length", lambda p,q: q.update(final_character_count=10000), "exact_final_text_and_caret")
    reject("wrong final caret", lambda p,q: q.update(final_selection_location=5999), "exact_final_text_and_caret")
    reject("final fixture mismatch", lambda p,q: q.update(final_fixture_matches=False), "zero_fixture_mismatches")
    reject("selection outside interval", lambda p,q: q["samples"][3].update(timestamp=99.5), "select_all_and_end_restoration_during_updates")
    reject("no restoration event", lambda p,q: q["samples"].pop(4), "select_all_and_end_restoration_during_updates")
    reject("restoration outside interval", lambda p,q: q["samples"][4].update(timestamp=110.01), "select_all_and_end_restoration_during_updates")
    reject("wrong select-all length", lambda p,q: q["samples"][3].update(selection_length=2999), "select_all_and_end_restoration_during_updates")
    reject("restoration is not explicit selection callback", lambda p,q: q["samples"][4].update(event="text"), "select_all_and_end_restoration_during_updates")
    reject("aggregate text count cannot prove timing", lambda p,q: [r.update(event="selection") for r in q["samples"] if r["event"] == "text"], "timestamped_typing_overlap")
    reject("negative selection", lambda p,q: q["samples"][1].update(selection_location=-1), "probe_sample_fields")
    reject("unordered probe events", lambda p,q: q["samples"][4].update(timestamp=103.9), "probe_sample_fields")
    reject("wrong fixture identity", lambda p,q: q.update(fixture_unit="other"), "fixture_identity")
    reject("unregistered probe identity", lambda p,q: q.update(own_bundle_identifier="unregistered"), "probe_identity")
    reject("missing all-callback text count", lambda p,q: q.pop("text_event_count"), "text_callback_count")
    reject("sampled text exceeds aggregate", lambda p,q: q.update(text_event_count=1), "text_callback_count")
    reject("missing probe sample object", lambda p,q: q["samples"].append(None), "probe_sample_fields")

    # The additional cases exercise only the newly required text-focus boundary.
    reject("missing text-focus aggregate", lambda p,q: q.pop("unexpected_text_focus_event_count"), "zero_unexpected_text_focus_events")
    reject("hidden text-focus violation", lambda p,q: q.update(unexpected_text_focus_event_count=1), "zero_unexpected_text_focus_events")
    reject("retained text window not key", lambda p,q: q["samples"][1].update(window_key=False), "zero_unexpected_text_focus_events")
    reject("retained text app inactive", lambda p,q: q["samples"][1].update(app_active=False), "zero_unexpected_text_focus_events")
    reject("missing retained text key flag", lambda p,q: q["samples"][1].pop("window_key"), "zero_unexpected_text_focus_events")
    reject("missing retained text active flag", lambda p,q: q["samples"][1].pop("app_active"), "zero_unexpected_text_focus_events")

    with tempfile.TemporaryDirectory(prefix="goal-layer-analyzer-synthetic-") as directory:
        directory = Path(directory)
        pulse_path, probe_path, output = [directory / name for name in
                                         ("constructed-pulses.json", "constructed-probe.json", "constructed-summary.json")]
        pulse_path.write_text(json.dumps(pulses))
        probe_path.write_text(json.dumps(probe))
        command = [sys.executable, str(Path(__file__).resolve()), str(pulse_path), str(probe_path)]
        result = subprocess.run(command + ["--output", str(output)], capture_output=True, text=True)
        ensure(result.returncode == 0 and json.loads(result.stdout)["passed"]
               and json.loads(output.read_text()) == json.loads(result.stdout), "CLI positive/summary case")
        names.append("CLI positive and exact summary output")
        original = pulse_path.read_text()
        result = subprocess.run(command + ["--output", str(pulse_path)], capture_output=True, text=True)
        ensure(result.returncode == 2 and pulse_path.read_text() == original, "Input overwrite protection")
        names.append("CLI input overwrite protection")
        bad = copy.deepcopy(pulses)
        bad["samples"][0]["frontmost_is_focus_probe"] = False
        pulse_path.write_text(json.dumps(bad))
        result = subprocess.run(command, capture_output=True, text=True)
        ensure(result.returncode == 1 and not json.loads(result.stdout)["passed"], "CLI failing evidence status")
        names.append("CLI failing evidence exit 1")
        for label, invalid in [("malformed JSON", "{"), ("non-object JSON", "[]"),
                               ("duplicate JSON key", '{"schema":"a","schema":"b"}'),
                               ("non-finite JSON number", '{"started_at":NaN}')]:
            pulse_path.write_text(invalid)
            result = subprocess.run(command, capture_output=True, text=True)
            ensure(result.returncode == 2 and "Traceback" not in result.stderr, "CLI " + label)
            names.append("CLI " + label + " exit 2")
        help_result = subprocess.run([sys.executable, str(Path(__file__).resolve()), "--help"],
                                     capture_output=True, text=True)
        ensure(help_result.returncode == 0 and "Required analysis command:" in help_result.stdout,
               "CLI help includes required analysis command")
        names.append("CLI help includes required command")

    return {"schema": "native-focus-analyzer-self-test-v1", "passed": True,
            "case_count": len(names), "cases": names,
            "scope": "Constructed synthetic analyzer inputs only; no native reports or UI used."}


def main():
    parser = argparse.ArgumentParser(
        description="Check the recorded synthetic 100-update focus/typing fixture. Missing evidence fails.",
        epilog="Required analysis command: python3 scripts/analyze-focus-check.py "
               "docs/evidence/M1-focus-pulses.json docs/evidence/M1-focus-probe.json "
               "--output docs/evidence/M1-focus-analysis.json. "
               "Exit status: 0 = recorded checks pass; 1 = checks fail; 2 = invalid input/output. "
               "The expected fixture is 6000 characters, with select-all/end restoration at 3000 "
               "inside the reported pulse interval. Reproduce constructed cases with "
               "python3 scripts/analyze-focus-check.py --self-test. No UI is run.")
    parser.add_argument("pulse_report", nargs="?", type=Path, help="native-focus-pulses-v1 JSON report")
    parser.add_argument("probe_report", nargs="?", type=Path, help="synthetic-focus-probe-v2 JSON report")
    parser.add_argument("--output", "--summary-output", type=Path,
                        help="optional JSON summary path; never an input report path")
    parser.add_argument("--self-test", action="store_true",
                        help="run the constructed 44-case suite plus six text-focus cases; no native evidence")
    args = parser.parse_args()
    if args.self_test:
        if args.pulse_report or args.probe_report or args.output:
            parser.error("--self-test does not take reports or an output path")
        try:
            sys.stdout.write(json.dumps(run_constructed_tests(), indent=2) + "\n")
            return 0
        except AssertionError as error:
            sys.stderr.write("Constructed analyzer test failed: " + str(error) + "\n")
            return 1
    if args.pulse_report is None or args.probe_report is None:
        parser.error("pulse_report and probe_report are required for analysis")
    try:
        if args.output and args.output.resolve() in (args.pulse_report.resolve(), args.probe_report.resolve()):
            raise ValueError("Summary output must not overwrite an input report")
        result = analyze(load_report(args.pulse_report), load_report(args.probe_report))
        result["input_files"] = {"pulses": args.pulse_report.name, "probe": args.probe_report.name}
        rendered = json.dumps(result, indent=2, allow_nan=False) + "\n"
        if args.output:
            args.output.write_text(rendered)
        sys.stdout.write(rendered)
        return 0 if result["passed"] else 1
    except (OSError, ValueError, TypeError) as error:
        sys.stderr.write("Focus analysis input/output error: " + str(error) + "\n")
        return 2


if __name__ == "__main__":
    sys.exit(main())
