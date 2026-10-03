#!/usr/bin/env python3
"""Sample only the given Goal Layer PID. No process inventory or captured content."""
import argparse
import json
import subprocess
import time
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--pid", type=int, required=True)
parser.add_argument("--seconds", type=int, default=600)
parser.add_argument("--interval", type=int, default=10)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()

def cpu_seconds(value):
    parts = value.strip().split(":")
    return float(parts[-1]) + (int(parts[-2]) * 60 if len(parts) > 1 else 0) + (int(parts[-3]) * 3600 if len(parts) > 2 else 0)

start = time.monotonic()
samples = []
while True:
    elapsed = time.monotonic() - start
    result = subprocess.run(["ps", "-p", str(args.pid), "-o", "time=,rss="], capture_output=True, text=True, check=True)
    raw = result.stdout.split()
    if len(raw) != 2:
        raise SystemExit("Target process exited; sample is incomplete.")
    samples.append({"elapsed_seconds": round(elapsed, 3), "cpu_seconds": cpu_seconds(raw[0]), "resident_kib": int(raw[1])})
    if len(samples) == 1 or len(samples) % 6 == 0:
        print(f"Resource sample: {elapsed:.0f}s, resident {int(raw[1])/1024:.1f} MiB", flush=True)
    if elapsed >= args.seconds:
        break
    time.sleep(min(args.interval, args.seconds - elapsed))
duration = samples[-1]["elapsed_seconds"] - samples[0]["elapsed_seconds"]
average = 100 * (samples[-1]["cpu_seconds"] - samples[0]["cpu_seconds"]) / duration
summary = {"schema": "goal-layer-resource-sample-v1", "method": "ps cumulative CPU delta / monotonic duration; RSS in KiB", "duration_seconds": duration,
           "average_cpu_percent_one_core": round(average, 4), "max_resident_mib": round(max(s["resident_kib"] for s in samples) / 1024, 3),
           "samples": samples, "memory_after_30_minutes": "not measured by this sample"}
args.output.write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k:v for k,v in summary.items() if k != "samples"}), flush=True)
