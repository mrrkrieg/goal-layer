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
- At least 100 timestamped input/open operations for P95 latency. The current guard-build CPU/memory windows passed; exact source/workload and reports are recorded below.
- Full native walkthrough recording and fresh contributor review of that matrix.

The next incomplete milestone is M1. M2 is not activated under the original strict dependency order. The pending user question asks whether to retain that order or allow M2 development while M1 stays explicitly incomplete. No reply has been assumed.

## Clean source build and CI follow-up

Initial source commit: `d9abcc37ca60f7779abfb88a3114b9439756763f`. A fresh separate local clone, containing no build output, ran `./scripts/test.sh` (16/16, 27.32 seconds including cold compilation) then `./scripts/build-app.sh` (10.56 seconds). Both succeeded. The first attempt called the scripts from the parent directory and failed before running a check; the corrected invocation ran from the clone root.

[CI run](https://github.com/mrrkrieg/goal-layer/actions/runs/37132653335) succeeded on macOS 15.7.9 (24G830), arm64, Swift 6.0.3, SDK 15.2. It passed 16 geometry assertions and built the app (5.03 seconds). This adds headless build/geometry evidence for macOS 15.7.9, not UI/Spaces/fullscreen evidence.

## Coordinated-focus tooling follow-up

The opt-in QA now supports timestamped pulse reports and a synthetic start marker. The temporary Focus Probe checks every own-field callback, retains compact samples and all failures, and writes only counts/selection/focus/fixture-match flags on normal termination. It does not store entered text. Its explicit start button focuses the fixture before creating the marker; that newly added button and explanatory layout compiled but have not been visually verified. [QA procedure](../M1_QA.md) records the exact launch and analysis commands.

A first direct-launch follow-up entered 10,000 exact synthetic characters, with zero fixture mismatches and no sampled typing focus loss during the overlap. It had incomplete shortcut timing and frontmost identity; [summary](M1-focus-uncoordinated-summary.json) reports that failure. A second LaunchServices trial ended with exactly 6,000 fixture characters, correct caret, and zero all-callback fixture/caret failures, but its select-all action occurred after the 100-update interval. It also does not pass the full gate. The next trial was interrupted by concurrent user input; it was invalidated, its helper closed, and its reports kept outside the public checkout. No entered user text was retained in reports or published.

The pulse interval is now 250 ms to provide roughly 25 seconds for the same 100 updates. The helper is centered by default and explains why it is open; maximization is explicit. Further attended native typing/shortcut verification remains pending. No recording or complete zero-interference result is claimed.

`python3 scripts/analyze-focus-check.py --self-test` exited 0: all 50 constructed cases passed. [Exact output](M1-focus-analyzer-self-test.json) lists positive, malformed/missing evidence, timing, mismatch, caret, focus, and CLI cases. These validate the report checker using constructed data, not actual native interaction. CI now runs this check in addition to geometry/build checks.

A cold build after relocating the checkout initially failed because an ignored Swift module cache contained the former temporary-root path. The generated `.build` directory was moved aside and regenerated; `./scripts/build-app.sh` then passed in 32.42 seconds. The final QA-instrumented app build passed in 2.20 seconds, the updated helper build passed, `./scripts/test.sh` passed 16/16 again, and the app's ad-hoc signature verification passed. [Current QA source/binary fingerprints](M1-qa-source-hashes.json) supplement the preserved original native fingerprints.

A clean collapsed `--demo` instance was measured with the v2 PID-only resource sampler for 1,800 seconds, covering the first ten-minute CPU window and memory at thirty minutes. Its completed CPU failure and subsequent passing builds are recorded below. Unrun display/Spaces/fullscreen/accessibility/latency/recording gates above remain required.

[QA CI run 37136042580](https://github.com/mrrkrieg/goal-layer/actions/runs/37136042580) passed for source `098d32d59e2664ca2b002ed643759d67f3a4fcb8`: macOS 15.7.9 (24G830), Swift 6.0.3, SDK 15.2; 16/16 geometry assertions, 50 constructed analyzer cases, and app build (7.36 seconds). The public remote head was independently verified against that source hash. This remains headless build/checker evidence. CI is also being extended to compile the standalone synthetic typing helper; it does not launch either UI.

## Resource-budget failure and pointer optimization

The 1,800.008-second clean QA-build sample completed. [Raw report](M1-resource-sample-qa-before-fix.json): the first CPU window lasted 600.735 seconds, cumulative process CPU grew from 0.80 to 7.30 seconds, and its average was **1.082% of one logical core**. This fails the unchanged <1% target. Memory at 1,800.008 seconds was **50.172 MiB** (52.609 MB decimal), below 150 MB; maximum sampled RSS was 67.641 MiB. The app was left collapsed with observation/animations inactive while other desktop use continued. This is a failed CPU gate, not a rounded-down pass or a thirty-minute CPU average substituted for the required ten-minute window.

A subsequent five-second `sample` of only the verified Goal Layer process showed its main/event threads waiting in the native event loop; it did not capture an active hot path. The raw stack report remains local. Code inspection found that every global pointer movement allocated a rounded path, including points far outside the panel, and called the mouse-ignore setter even when its desired value had not changed. The optimization rejects positions outside the inclusive rectangular bounds before allocating the rounded path and invokes the setter only on a change. Inclusive bounds preserve CGPath's existing edge decision. This is a plausible reduction in repeated work; the idle stack sample does not prove it was the sole cause.

After that change, `./scripts/test.sh` passed 16/16 and `./scripts/build-app.sh` passed (1.99 seconds); the collapsed app was restarted cleanly. [Optimized source/binary fingerprints](M1-pointer-optimized-source-hashes.json) identify the build measured in the completed optimized follow-up below. Native pointer behavior still requires the controlled corner/click/drag walkthrough. At that point the complete M1 resource gate remained incomplete; the later completed results are recorded below.

[CI run 37136481667](https://github.com/mrrkrieg/goal-layer/actions/runs/37136481667) passed for source `e747ced115926732512109376b469e60d6d0d504`, including app and synthetic typing-helper compilation, 16 geometry assertions, and 50 constructed analyzer cases. It predates the pointer optimization and contains no native UI evidence.


## Completed pointer-optimized resource result

The optimized run completed naturally; its earlier terminal handle had expired, so the completed report and target process were checked rather than restarting or replacing the measurement. [Raw optimized report](M1-resource-sample-pointer-optimized.json) contains 181 samples over **1,800.010 seconds**. Its predetermined ten-minute CPU window was **600.702 seconds**: cumulative CPU rose from 0.17 to 4.01 seconds, giving **0.6393% of one logical core**, below the unchanged 1% target. RSS after thirty minutes was **28.5 MiB / 29.884416 MB decimal**, below 150 MB; maximum sampled RSS was 68.125 MiB. The corresponding [source/binary fingerprint](M1-pointer-optimized-source-hashes.json) matched the sampled build before further native-shell edits.

The whole thirty-minute CPU average was **1.3522%**. That is additional workload context, not a substitute for the specified ten-minute window. Other desktop use continued; no other app content or activity was recorded. The result establishes this run's measured values, not a universal CPU bound or proof that pointer handling was the sole cause of the earlier failure. Preserve the preceding 1.082% failed report.

[Pointer-optimization CI run 37137288332](https://github.com/mrrkrieg/goal-layer/actions/runs/37137288332) passed for source `5ebb599950c322f9662a6585698397f3b3b22abe`: native bundle/helper compilation, 16 geometry assertions, and 50 constructed analyzer cases. This remains headless evidence.

## Fullscreen/Space guard implementation follow-up

Source review found explicit expansion and planning-window activation were not protected by omission of fullscreen collection behaviors alone. The implementation now observes the public system fullscreen presentation flag, initializes suppression before ordering, and checks it again before deliberate access and reconciliation. It preserves brief entry events through a Boolean passed to the main actor, uses fresh system options for current visibility, and restores only a collapsed nonkey pill. Window Space prediction precedes taking key or activating the app. The ordinary planning window moves toward the active Space and disallows fullscreen/secondary tiling; a failed prediction refuses activation. Recovery menus retain disabled access plus an explanation during fullscreen and update already-tracking menus in place. Manual hiding, presentation mode, and drafts remain separate. [ADR-003](../DECISIONS.md#adr-003-overlay-ownership-access-and-fullscreen-fallback) records policy, primary API references, and per-display limitations.

The final local `./scripts/build-app.sh` passed in **2.64 seconds** with Swift 6 / SDK 15.2; `./scripts/test.sh` passed **16/16** and `codesign --verify --deep --strict build/Goal\ Layer.app` passed. An independent source review identified transient-entry and tracking-menu gaps; both were corrected and re-reviewed. This is source/build evidence, not a native fullscreen pass.

The own-app native tool restarted the bundle through its Quit action and observed its collapsed introduction. Clicking expanded the updated native panel and exposed its goal-draft and accessible controls. The following Escape action was rejected because concurrent user input changed the app; the next scoped AX observation found the panel collapsed. This does not establish a new controlled Escape/focus-restoration result. No typing helper was reopened. Further native interaction is reserved for an uninterrupted test period.

A new PID-only thirty-minute sample was started against the freshly restarted guard build, initially collapsed with no pulse/test flags and no activity/animation pipeline. [Guard build fingerprint](M1-fullscreen-guard-source-hashes.json) distinguishes it from the earlier passing build. Its completed result is recorded below. The required fullscreen, display removal/wake, accessibility, latency, controlled typing/pointer and recording gates remain incomplete. M2 is still not activated.


[Guard CI run 37167052415](https://github.com/mrrkrieg/goal-layer/actions/runs/37167052415) passed for source `e48104af81d09d4c5b25a921cb907009a67e417c`: macOS 15.7.9 (24G830), arm64, Swift 6.0.3 / swift-driver 1.115.1, SDK 15.2, pinned Xcode 16.2; 16 geometry assertions, 50 constructed analyzer cases, native app build (8.75 seconds), and synthetic typing-helper build. The public remote head matched this source hash after push. No native GUI/Spaces/fullscreen pass is implied.


## Completed guard-build resource result

[Raw guard-build report](M1-resource-sample-fullscreen-guard.json) contains **181 samples over 1,800.009 seconds**. The predetermined CPU window was **600.704 seconds**; cumulative CPU increased from **0.96 to 4.59 seconds**, giving **0.6043% of one logical core**, below 1%. RSS at thirty minutes was **39,568 KiB = 38.640625 MiB** (reported 38.641 MiB) **= 40.517632 MB decimal**, below 150 MB. Maximum sampled RSS was 75.969 MiB. The whole-run CPU average was 0.3689%, reported as additional context rather than substituted for the required ten-minute window.

The sampler exited 0. Its target was verified at start and finish as the own Goal Layer bundle, with no launch arguments or QA pulse flags. The default synthetic introduction had been expanded once before sampling and was observed collapsed at sampling start; the agent made no foreground app interactions during the measurement. Other desktop use continued and was not recorded. All [source and signed-binary fingerprints](M1-fullscreen-guard-source-hashes.json) still matched after completion; the native code is the published `e48104af81d09d4c5b25a921cb907009a67e417c` source. Device/OS were rechecked: Mac17,2, Apple M5, 10 logical cores, 16 GiB RAM, macOS 26.5 (25F71), arm64. No device serial/UUID or other app content was collected.

This passes the specified resource windows for this build and workload. Keep the prior failed and passing runs with their separate scopes; differing desktop activity and synthetic states prevent assigning all variation to a single code change. P95 input/open latency remains unmeasured. Controlled typing/pointer/focus, physical display/wake, fullscreen/Spaces/Stage Manager, full accessibility and native recording gates remain incomplete. M1 is not accepted and M2–M7 remain planned.
