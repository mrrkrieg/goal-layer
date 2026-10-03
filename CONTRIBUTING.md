# Contributing to Goal Layer

Goal Layer is being implemented one milestone at a time. The local foundation is prepared and M1 native interaction work is in progress. Use [Status](docs/STATUS.md) to find the next incomplete milestone and the checks that still need evidence. Repository publication and a binary release are separate tasks; neither is implied by local files.

Read these documents in order before implementation:

1. [AGENTS.md](AGENTS.md)
2. [Product specification](docs/PRODUCT_SPEC.md)
3. [UX specification](docs/UX_SPEC.md)
4. [Scoring](docs/SCORING.md)
5. [Architecture](docs/ARCHITECTURE.md)
6. [Roadmap](docs/ROADMAP.md)
7. [Open-source plan](docs/OPEN_SOURCE.md)

Then read [Decisions](docs/DECISIONS.md) for implementation-driven changes. The roadmap owns milestone IDs and gates; scoring owns rewards and provenance; UX owns interaction requirements; architecture owns technical boundaries. Preserve unrelated work. If independent tasks run in parallel, assign explicit file ownership and reconcile evidence before acceptance.

## Build and demonstrate

The recorded M1 baseline is macOS 26.5 (25F71) arm64, Swift 6.0.3, and Command Line Tools SDK 15.2. Full Xcode is unavailable. macOS 14 is intended and unverified. See the exact toolchain and support limits in [Decisions](docs/DECISIONS.md).

From the project root:

```sh
./scripts/build-app.sh
./scripts/test.sh
open build/Goal\ Layer.app --args --demo
```

The originally attempted `swift test --scratch-path .build --disable-sandbox` fails here with `no such module XCTest`; the available Command Line Tools installation lacks that module. Use the deterministic standalone `GoalLayerChecks` executable through `scripts/test.sh` for the geometry checks. Record its actual results and add meaningful checks for changed boundaries. Inspect contributed manifests and scripts before running them. A passing geometry check or successful compile does not establish native focus, Spaces, fullscreen, accessibility, display, or resource behavior.

M1 demonstrations use synthetic data only. Manual product state, SQLite, real rewards, AI, activity observation, browser integration, capture, and community services belong to later milestones. Do not request activity permissions or remote credentials to run the native spike.

The [M1 QA procedure](docs/M1_QA.md) covers the explicit temporary typing window, coordinated synthetic reports, remaining native matrix, and resource sampling. Keep any interrupted or nonsynthetic run private.

## Changes and acceptance evidence

Keep a change tied to a named milestone and its smallest usable result. A contribution should explain the concrete problem, resulting behavior, affected acceptance gates, and remaining limitations. Record:

- The command or interaction performed and its actual result, including failures and not-run checks.
- Toolchain, OS build, CPU architecture, and relevant display/hardware configuration for native checks.
- Fixture identity, seed, expected result, and observed result when replay or accounting matters.
- A short synthetic demonstration when the behavior is visual, alongside interaction evidence when a screenshot cannot prove it.
- New data collected, retained, transmitted, exported, or deleted, and the exact consent boundary.
- Dependencies/assets introduced, their source, attribution, license, and redistribution rights.

Use the [pull request template](.github/pull_request_template.md). Update [Status](docs/STATUS.md) with evidence references after verification; never turn a target into a measured result. A milestone remains incomplete when a material gate fails or required hardware is unavailable. Fix the cause or document the precise unsupported configuration without silently weakening the gate.

## Policy and data-contract changes

Before changing dependent specifications, write a concrete decision in [Decisions](docs/DECISIONS.md): the observed problem, chosen change, alternatives, consequences, owner, and blocking milestone. Resolve conflicts before implementing dependent behavior.

For a scoring-policy change, propose a new version and explicit migration behavior. Preserve accepted quest versions, stable work-unit credit keys, frozen allocations, and explainable grant/reversal history. Do not silently recompute existing balances, add XP through quest splitting, or treat model confidence as reward authority. Add meaningful accounting/replay checks when those boundaries change.

For a persisted or wire-contract change, describe old/new schema versions, compatibility, validation, migration, failure recovery, privacy/deletion consequences, and fixture updates. An assessment must not gain executable tools, reward amounts, or acceptance authority. Platform adapters supply evidence; the deterministic completion boundary owns rewards. Future shared scores are computed by the service from accepted challenge units.

## Repository scope and licensing

Use synthetic fixtures and original assets. Exclude private user/company/customer material, activity histories, real contacts, credentials, provider payloads, screenshots of private work, and local evidence databases. Review recordings, exports, and logs before adding them. Ignore rules are a convenience, not evidence that a contribution is safe to publish.

Contributions to original project material use the [MIT license](LICENSE) and preserve the Goal Layer contributors attribution. Imported material keeps its own required notices. Update [Third-party notices](THIRD_PARTY_NOTICES.md) before adding external code or assets. Linking to a research reference does not grant reuse rights to its text or artwork.

Follow the [Code of conduct](CODE_OF_CONDUCT.md). Report sensitive vulnerabilities through the route described in [Security](SECURITY.md); public issues must not include secrets or private evidence.
