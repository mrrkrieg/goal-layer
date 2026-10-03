# Implementation decisions

Recorded 2026-10-03 for the local M0 foundation. These decisions resolve implementation dependencies; they are not runtime acceptance evidence. [ROADMAP.md](ROADMAP.md) retains ownership of milestone gates. [STATUS.md](STATUS.md) records what was actually checked.

## ADR-001: Native build route and toolchain

**Status:** accepted for M1. **Owner:** native app maintainer. **Dependency:** M1.

The available Mac has Command Line Tools rather than full Xcode. Requiring the proposed Xcode app target now would block the native spike without improving its acceptance evidence. Use a SwiftPM executable for SwiftUI/AppKit source and `scripts/build-app.sh` to create a native `build/Goal Layer.app` bundle with its executable and Info.plist. This is the concrete replacement for the proposed M1 Xcode app target in the architecture source-layout table. Native AppKit window ownership and SwiftUI presentation remain the chosen approach.

The inspected baseline is:

| Item | Value recorded from the environment |
| --- | --- |
| OS | macOS 26.5, build 25F71 |
| CPU architecture | arm64 |
| Swift | Apple Swift 6.0.3, swift-driver 1.115.1 |
| Swift compiler identifier | swiftlang-6.0.3.1.10 |
| Clang identifier reported by Swift | clang-1600.0.30.1 |
| Selected developer directory | `/Library/Developer/CommandLineTools` |
| macOS SDK | 15.2 |
| SDK path | `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk` |
| Full Xcode | Unavailable in this environment |
| Swift language mode | Swift 6, explicitly configured with `swiftLanguageModes: [.v6]` |
| Third-party package versions | None selected for M1; inventory must match actual manifest/source |
| Hosted CI runner | Workflow pins `macos-15` and `/Applications/Xcode_16.2.app`; execution pending |

The Swift toolchain prints a default target of `arm64-apple-macosx16.0`. `Package.swift` explicitly sets `platforms: [.macOS(.v14)]`; the resulting artifact and actual macOS 14 compatibility still require validation. The default target output does not prove either. Build availability and actual runtime compatibility remain separate checks.

Development entry points are `./scripts/build-app.sh`, `./scripts/test.sh`, and `open build/Goal\ Layer.app --args --demo`. The attempted `swift test --scratch-path .build --disable-sandbox` failed with `no such module XCTest` because XCTest is unavailable in the selected Command Line Tools installation. Use a deterministic standalone `GoalLayerChecks` executable for geometry assertions through `scripts/test.sh`; full Xcode/XCTest is not a prerequisite for this M1 build route. A script existing or a check passing does not establish native interaction. Record each command's result and the M1 walkthrough before accepting the milestone.

A full Xcode project may be introduced when a concrete development/distribution requirement justifies it. Document that decision and keep the clean source build reproducible. The shell bundle is a local development artifact; signing, notarization, integrity, and distribution are M7 gates.

## ADR-002: Deployment intent and tested support

**Status:** accepted support-claim boundary. **Owner:** native app maintainer. **Dependency:** M1 evidence and M7 release.

Keep macOS 14.0 as the intended deployment target. Only macOS 26.5 arm64 is currently available to run native checks. Minimum-OS and previous-OS checks are unverified, and Intel support is outside the initial claim until tested. A successful compile against SDK 15.2 must not be reported as macOS 14 runtime support.

Run M1 development on the available Mac and list every unavailable configuration explicitly. Do not accept required display/Space/fullscreen/accessibility/performance gates from a mocked test or screenshot. Before a release, either demonstrate the intended minimum and declared configurations or narrow the published support claim with a documented decision. Device model and display configuration must accompany native resource and placement evidence.

## ADR-003: Overlay ownership, access, and fullscreen fallback

**Status:** accepted for M1. **Owner:** native app maintainer. **Dependency:** M1.

Use an accessory app with a recoverable menu-bar item, an AppKit NSPanel created as nonactivating, SwiftUI content, and a normal management window. The collapsed pill must intercept only its visible bounds and never activate from background updates. Intentional expansion/text entry and dismissal must be verified through the actual responder chain.

Place one pill below the menu bar/camera safe area using live screen-point geometry. Recompute safe bounds on display changes; fall back to an available primary display if the selected display disappears. Display pinning, unplug/replug, scaling, and wake remain native gates.

Do not rely on screenSaver-level windows, private APIs, forced reordering, or changing another app's Space/fullscreen state. Use conservative hiding where an ordinary-level overlay cannot be demonstrated reliably in fullscreen, with menu access to the ordinary window and explicit restoration available. Manual Hide overlay must remain reachable. Detecting or automatically hiding in every fullscreen or screen-sharing context is not claimed until implemented and tested.

No global shortcut is registered initially. Click/menu access must work. The fallback has no shortcut behavior to promise in this iteration. A future configurable shortcut starts unassigned, uses a public registration API, preserves system/VoiceOver combinations, and falls back to click/menu if registration fails. Key recording is not an acceptable implementation route.

## ADR-004: M1 synthetic presentation and M2 local storage

**Status:** accepted. **Owner:** native maintainer for M1; domain/store maintainer for M2. **Dependency:** M1/M2.

M1 is an interaction spike using only synthetic in-memory goal/quest/world state. Any progress or reward-like visual update is a fixture, not a real accepted completion or persistent award. Do not add observation, capture, network, model/provider, account, community, or real evidence storage to this slice.

M2 uses a pure Swift domain boundary and system SQLite3 with one repository actor owning writes. Explicit transactions atomically accept completion decisions and eligible awards; policy-defined uniqueness prevents replay/concurrency duplicates. Enable/check foreign keys and retain linked reversals. Award presentation follows commit and has no ledger authority. Do not use SwiftData for the first store. Credentials belong in Keychain when credential features begin, not in SQLite or fixtures.

The M2 manual offline goal-to-reward/world loop is still planned. Its restart, undo, replay, deletion/export, and placement-choice fixtures must pass before its persistence or scoring is described as implemented.

## ADR-005: Optional AI, context, and community boundaries

**Status:** accepted sequencing and authority boundary. **Owner:** corresponding milestone maintainer. **Dependency:** M3–M6.

Start AI work with a typed provider interface, deterministic mock, and usable no-AI/manual path in M3. Cloud BYOK and same-Mac local endpoint adapters are separate opt-in destinations; never fall back to cloud silently. Models recommend drafts or pending assessments. They cannot accept completion, return authoritative rewards, execute tools, or alter consent/policy. Select real provider/model versions when that work starts and record evaluation results against fixed fixtures.

M4 may introduce session-scoped app bundle-ID context and selected Chrome evidence. Browser gesture mode and allowlisted background-origin mode have distinct grants. Selected screen capture/OCR is a separately gated M5 stretch item. Observation is evidence input and never an independent reward. Preserve privacy epochs, bounded payloads, exclusions, pause, retention, and deletion boundaries.

M6 may introduce an optional TypeScript/Fastify/PostgreSQL service with REST and persistent SSE. It owns challenge eligibility, accepted units, scores, and membership authorization. Personal XP never becomes competitive authority. No hosted service is needed for personal use. Authentication/package versions and the initial production verifier are intentionally selected at their milestone; no current infrastructure or integration is implied.

## ADR-006: Repository scope, original rights, and publication

**Status:** accepted local foundation. **Owner:** project/release maintainer. **Dependency:** M0 scope and M7 distribution.

Keep Goal Layer in its own project directory. Include project specifications, original source/assets, synthetic fixtures, contributor material, and reviewed milestone evidence. Exclude private user/company/customer material, actual activity, contacts, credentials, and unreviewed captures or exports. Preserve the MIT attribution to Goal Layer contributors and inventory external licenses before import.

Local preparation, Git initialization/commit, public repository creation, source push, release tagging, and binary publication are separate observable events. No public URL or release is claimed here. Private security/conduct reporting and release signing/update policies must be configured before opening the corresponding public participation/distribution path.

## Remaining decisions and owners

No unresolved architectural choice blocks the M1 build route or the choice of M2 storage. The following choices/evidence remain explicitly open:

| Open item | Owner | Blocking milestone/action |
| --- | --- | --- |
| Actual reference device model and tested display/Space/fullscreen/accessibility matrix | Native app maintainer | M1 native acceptance and resource measurements |
| Minimum/previous OS and additional hardware availability, or a narrower release support claim | Native/release maintainer | Declared platform support before M7 distribution |
| SQLite schema, migrations, attachment retention/deletion contract | Domain/store maintainer | M2 persistence and accounting acceptance |
| Real AI provider/model identifiers and fixed evaluation adjudication | AI maintainer | M3 provider/evaluation claims |
| Initial verifier audience, exact predicate, binding, freshness/revocation semantics | Integration maintainer | M5 verifier and pilot |
| Community authentication/dependency versions and verified moderation/deletion routes | Community maintainer | M6 multi-user service |
| Public repository destination, CI runner, private security/conduct reporting, signing/notarization and update policy | Release maintainer | Public participation and M7 distributed beta |

An owner is a responsibility in this project, not a claim that a person/account or external service has already been appointed. Resolve each item before dependent behavior is accepted and add evidence to the status record.

## CI and source publication addendum

The official [macOS 15 runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md) lists Xcode 16.2 and SDK 15.2. The workflow pins that developer directory and the checkout action commit `11d5960a326750d5838078e36cf38b85af677262`. Runner images can change; the workflow records actual versions and fails when its selected Xcode is unavailable. CI validates builds and geometry only, never native focus/Spaces/VoiceOver.

The public destination was verified as `mrrkrieg/goal-layer` using authenticated GitHub CLI and connector identity checks. Repository creation and public visibility are verified; source push and CI are recorded separately. Native display preferences now use the public ColorSync display UUID conversion; temporary display numbers are not persisted.
