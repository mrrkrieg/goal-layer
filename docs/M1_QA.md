# Native M1 QA procedure

M1 remains incomplete. This procedure prepares measurements; running an analyzer or building a bundle is not native acceptance. Use only this project and synthetic test text. The current actual results are in [the native record](evidence/M1-native-record.md).

## Scope and setup

Quit existing Goal Layer and Focus Probe test instances through their own menus before a new run. LaunchServices reuses a running instance and can ignore new arguments. Keep a dedicated, uninterrupted test interval; concurrent user input invalidates a typing run. Do not move or close unrelated windows, collect global keystrokes, or record the whole desktop.

```sh
./scripts/build-app.sh
./scripts/build-focus-probe.sh
./scripts/test.sh
python3 scripts/analyze-focus-check.py --self-test
```

The 16 geometry assertions and 50 constructed analyzer cases are separate from native evidence. The helper is a temporary conventional window explaining its purpose. It is centered by default; use `--maximized` only for the maximized-window test. Its new explanation/start-button layout has compiled but has not received a native visual walkthrough.

## Coordinated 100-update typing test

Create a fresh local QA directory so an old report or marker cannot be mistaken for a new run:

```sh
qa_dir=$(mktemp -d /private/tmp/goal-layer-focus.XXXXXX)
open -g "$PWD/build/Goal Layer.app" --args --demo --preview-pulses \
  --qa-start-file "$qa_dir/start" --qa-report "$qa_dir/pulses.json"
open "$PWD/build/Focus Probe.app" --args \
  --record "$qa_dir/probe.json" --start-marker "$qa_dir/start"
```

Within 60 seconds of launch, click **Start 100-update typing test**. That explicit action focuses the helper field and creates the marker without a terminal switch. Goal Layer waits one second, then applies exactly 100 synthetic preview updates about 250 ms apart. No ledger or reward exists in M1.

Through native character input, type `abcdefghij0123456789` repeated 150 times (3000 characters), press Command-A, press Right to restore the caret to the end, then type the same 3000-character sequence again. Pace input so typing and both shortcut actions occur during the roughly 25-second pulse interval. The previous native input tool entered 6000 characters in approximately 15–25 seconds. Pasting a whole block is not a lost-keystroke demonstration. Quit the helper through its own menu or Command-Q to save the report.

```sh
python3 scripts/analyze-focus-check.py "$qa_dir/pulses.json" "$qa_dir/probe.json" \
  --output "$qa_dir/analysis.json"
```

Exit 0 means these recorded checks pass, exit 1 means evidence fails, and exit 2 means input/output is invalid. Review timestamps and source state as well. Missing evidence fails. The analyzer requires all 100 pulses to find the known probe frontmost, no panel key/app activation samples, timestamped typing and select-all/end restoration inside the update interval, exact final text/caret, and zero all-callback fixture/caret/focus failures. It does not establish continuous focus between pulse samples or prove a physical shortcut sequence independently of the recorded interaction trace.

The opt-in helper compares its own text with the known fixture on every callback. It records lengths, selection positions, match/focus flags, and timestamps; it never stores text. Ordinary text and selection samples are retained at up to 20 Hz each; all failures, lifecycle events, nonempty selections, and selection restoration are retained. Reports are written on normal helper termination. Killing the helper without termination handling is an incomplete run. Goal Layer records only booleans about the known helper's identity, never another app's name/title/content.

Review synthetic reports before publishing. Keep interrupted or nonsynthetic runs private. Record the native interaction separately; these logs cannot replace the required demonstration.


## Fullscreen and Space fallback check

This guard is compiled and source-reviewed; the following native checks are still unrun. Use a blank synthetic page in Safari and Chrome and the synthetic Goal Layer draft. Enter fullscreen with the panel initially expanded, then reveal the menu bar. Confirm the pill hides, Open/Plan are disabled with the fullscreen explanation, and the recovery controls remain reachable without changing Space or exiting the browser. Leave fullscreen and confirm only the collapsed nonkey pill returns when hide/presentation preferences permit. Repeat with manual hiding and presentation mode enabled to ensure neither preference is cleared. Inspect brief fullscreen enter/exit, menu tracking during a transition, maximized windows, separate display Spaces, and Stage Manager on/off.

Open the ordinary planning window, switch to another normal Space, and request planning through the recovery menu. It must either open on the current Space after its public Space check succeeds, or remain unavailable with an explanation; the action must never switch Spaces. Recheck after close/minimize and display changes. The planning window disallows fullscreen and secondary fullscreen tiling in this spike. No global shortcut is assigned, including in fallback. A source review or hidden-window prediction alone cannot pass this matrix.

## Remaining native matrix

Record device/OS, display scale/geometry, command or action, result, and a short scoped demonstration for each applicable row. The roadmap's criteria remain unchanged.

| Check | Required observation |
| --- | --- |
| Open and dismiss | Pill click, menu open, Escape, close action, outside click, draft retained, and focus restored to the work window |
| Pointer bounds | Rounded corners/outside clicks and drags reach the underlying synthetic app; collapsed pill takes no keyboard focus |
| Displays | Built-in notch-safe placement; external pin/restart; physical unplug/replug; resolution change and wake recovery |
| Window/Space modes | Ordinary/maximized windows, Spaces, Stage Manager on/off, Safari/Chrome fullscreen; recovery menu remains reachable; no forced Space switch or exit from fullscreen |
| Accessibility | Keyboard order/names, full VoiceOver path, larger/long text, increased contrast, reduced transparency, static reduced-motion feedback |
| Responsiveness | At least 100 actual input/open operations; input-to-first-visible-feedback and input-to-usable-panel timestamps; P95 ≤100 ms and ≤200 ms respectively |
| Resource use | Final build, observation/animations inactive; ten-minute average CPU <1% of one logical core and resident memory <150 MB after thirty minutes |
| Compatibility | Actual native matrix on each declared supported OS/hardware; intended deployment metadata alone does not establish compatibility |

For resource sampling, verify the PID belongs to the clean Goal Layer bundle, then run:

```sh
python3 scripts/sample-resources.py --pid <verified-GoalLayer-PID> --seconds 1800 \
  --interval 10 --output <reviewed-local-synthetic-report.json>
```

The v2 sampler computes CPU from the initial sample through the first sample at/after 600 seconds, reports actual elapsed duration, and separately records RSS at/after 1800 seconds. The first sample in each timing window defines the measured interval. Report decimal MB versus MiB explicitly. An exited process yields an incomplete measurement. Other applications remain usable during the sample.

M2 depends on passed M1 under the requested roadmap. No unsupported hardware, interrupted input, pending measurement, or unrun recording is a pass.
