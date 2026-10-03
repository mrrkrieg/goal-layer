# M1 native spike evidence — October 3, 2026

M1 is **incomplete**. This record distinguishes actual native observations from unrun acceptance gates. It does not certify the complete personal app, macOS 14 compatibility, a public beta, or the final performance budget.

## Environment and source scope

Reference Mac: MacBook Pro `Mac17,2`, Apple M5, 10 logical cores, 16 GiB RAM; macOS 26.5 (25F71), arm64. Device serial/UUID and private app/window content were excluded. The attached displays were a 1512×982-point built-in notched display at 2× with a 32-point safe top inset, and a 1920×1080-point external display at 1×, arranged above the built-in display. [Sanitized geometry](M1-native-geometry.json) contains only screen geometry and this app's state.

Toolchain: Command Line Tools; Swift 6.0.3, swiftlang-6.0.3.1.10, clang-1600.0.30.1, SDK 15.2. Full Xcode/XCTest are absent locally. Source uses Swift 6 mode and macOS 14 deployment intent. Native source fingerprint is recorded in [source hashes](M1-source-hashes.json). Build artifacts are ignored and not publicly distributed.

## Commands and results

Commands were run from the isolated checkout; the final checkout is a separate repository beside the unrelated original workspace. Incidental absolute paths from build warnings are omitted here.

| Command | Actual result and boundary |
| --- | --- |
| `./scripts/build-app.sh` | Passed; release executable and native `.app` bundle built with SwiftUI/AppKit. Final incremental build: 2.28 seconds. Ad-hoc signature only. |
| `./scripts/test.sh` | Passed: 16/16 geometry and rounded hit-shape assertions. Does not certify native input/display behavior. |
| `swift test --scratch-path .build-tests --disable-sandbox` | Failed: `no such module XCTest`; replaced with the documented standalone assertion executable. |
| `open build/Goal\ Layer.app --args --demo` | Real native bundle opened. The tool sandbox initially returned LaunchServices error -10827; an authorized host launch succeeded. This was an environment boundary, not a successful sandboxed launch. |
| `xcrun vtool -show-build build/Goal\ Layer.app/Contents/MacOS/GoalLayer` | `LC_BUILD_VERSION`: platform MACOS, minos 14.0, sdk 15.2, linker 1115.7.3. This is metadata, not minimum-OS runtime proof. |
| `codesign --verify --deep --strict build/Goal\ Layer.app` | Passed for local ad-hoc signature; no notarization/distribution identity claimed. |
| `./scripts/build-focus-probe.sh` | Passed; original synthetic-only native text-entry fixture built. No global keystrokes or unrelated app content are collected by the probe. |

## Recorded native interaction trace

The native computer-use tool operated the real Mac application and returned its AX tree and cropped window screenshots. No browser rendering was used to pass native observations.

1. Clicked the collapsed pill: a 460×560-point expanded panel displayed the synthetic outcome, criterion, planned 40 XP, original world, and controls. Escape returned to the 300×36-point pill.
2. Opened the ordinary Plan/Settings window, typed `Synthetic draft: learn five SQL question types.`, closed it, reopened it, and verified the identical draft in the actual text field. This establishes in-launch draft preservation, not restart persistence.
3. Selected the attached external display through the native menu. Restarted the app and recorded its expanded frame at x=414, y=1464, width=460, height=560 on that display. The selected display persisted. Restored the built-in display afterward. [External geometry](M1-native-external.json) and [collapsed geometry](M1-native-collapsed.json) are sanitized.
4. Enabled Larger overlay text in native settings and reopened the panel. The current quest and Edit draft primary action remained visible in the initial viewport for this fixture. AX labels exposed the world, character choices, panel/window access, and controls. This is not a VoiceOver or arbitrary-long-title pass.
5. Used the QA app's standard Command-Q path; its test process exited with code 0. The recovery menu exposed Open, Plan/Settings, Hide, Presentation mode, Display, observation state, and Quit.

A complete keyboard/pointer/Spaces/fullscreen/wake video walkthrough has **not** been recorded. Outside-click dismissal occurred during native work, but prior-app focus restoration and corner/outside dragging require controlled verification.

## Background and resource samples

A separate native QA instance ran `--demo --expanded --preview-pulses`; after its initial delay it delivered 100 synthetic updates at 100 ms intervals. Its exact result was:

```
PREVIEW_PULSES count=100 key_samples=0 active_samples=0. Typing integrity needs a separate native check.
```

The synthetic native Focus Probe received an exact 1,000-character fixture through native computer-use input, with the complete sequence present in its AX value. The text entry was not timestamp-coordinated with every pulse. Consequently these observations do **not** pass the complete 100-update typing/shortcut/cursor gate, and no zero-lost-keystroke result is claimed for the entire update interval. No XP or ledger existed in the spike.

Resource command: `python3 scripts/sample-resources.py --pid <GoalLayer test PID> --seconds 600 --interval 10 --output docs/evidence/M1-resource-sample-initial.json`. The PID was verified as this app only. [Raw numeric sample](M1-resource-sample-initial.json): duration 600.01 seconds, average cumulative CPU delta 0.0283% of one logical core, maximum RSS 68.438 MiB. Observation/animations were inactive and the app was left idle. Other native QA instances were separate processes. This sample used the initial loaded spike before final display/pointer fixes; final-build idle verification and memory after 30 minutes remain pending. No P95 input/open latency measurement is claimed.

## Appearance

The [light preview](M1-observatory-light.png) and [dark preview](M1-observatory-dark.png) are actual renders of this app's own synthetic NSHostingView, not system-wide screen captures. They demonstrate appearance only. Dark preview was recorded on the external 1× display; light preview used the built-in 2× display. The world is original vector source. Default idle animation and sound are absent; feedback honors quiet/reduced-motion controls. Full assistive-technology behavior remains unverified.

## Unrun or incomplete gates

- Controlled 100-update typing/cursor/shortcut integrity and focus restoration in another app.
- Actual pointer corner/outside click-through and dragging after the new native rounded hit-region handling.
- Physical display unplug/replug, changed resolution, wake, and recovery with no usable display.
- Spaces, Stage Manager on/off, maximized windows, Safari/Chrome fullscreen and conservative menu access.
- Previous/minimum macOS hardware, Intel, full VoiceOver navigation, increased contrast and reduced transparency matrix, arbitrary long titles.
- Final-build ten-minute idle and memory after 30 minutes; at least 100 timestamped input/open operations for P95 latency.
- Full native walkthrough recording and fresh contributor review of that matrix.

The next incomplete milestone is M1. M2 is not activated under the original strict dependency order. The pending user question asks whether to retain that order or allow M2 development while M1 stays explicitly incomplete. No reply has been assumed.

## Clean source build and CI follow-up

Initial source commit: `d9abcc37ca60f7779abfb88a3114b9439756763f`. A fresh separate local clone, containing no build output, ran `./scripts/test.sh` (16/16, 27.32 seconds including cold compilation) then `./scripts/build-app.sh` (10.56 seconds). Both succeeded. The first attempt called the scripts from the parent directory and failed before running a check; the corrected invocation ran from the clone root.

[CI run](https://github.com/mrrkrieg/goal-layer/actions/runs/37132653335) succeeded on macOS 15.7.9 (24G830), arm64, Swift 6.0.3, SDK 15.2. It passed 16 geometry assertions and built the app (5.03 seconds). This adds headless build/geometry evidence for macOS 15.7.9, not UI/Spaces/fullscreen evidence.
