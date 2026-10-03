# Open-source repository and release plan
Current status: a reviewed specification bundle, prepared for a new repository. No remote repository or public binary has been created by this document.
1. Repository boundary
Use a new repository with the working name goal-layer. Naming and public availability have not been checked. Keep the project independent of any existing company application, customer workspace, or private monorepo.
Include the original product specification, future application source, synthetic fixtures, original assets, evaluations, and documentation. Exclude private user activity, company examples, credentials, customer data, model keys, and local captures.
The initial source bundle contains:
File	Purpose
README.md	Project status and contributor entry point
CODEX_TASK.md	Project-level assignment for Codex
AGENTS.md	Implementation and verification rules
docs/PRODUCT_SPEC.md	Product purpose, scope, and behaviors
docs/UX_SPEC.md	Interface, world, motion, and interaction contract
docs/ARCHITECTURE.md	Proposed modules, data flow, permissions, and limits
docs/SCORING.md	Deterministic points, provenance, and shared challenges
docs/ROADMAP.md	M0–M7 deliverables and acceptance criteria
docs/OPEN_SOURCE.md	This publication and release plan
docs/SOURCES.md	Primary research references and their limits
examples/goal-plan.json	Synthetic worked goal and scoring fixture
CONTRIBUTING.md	How to contribute
SECURITY.md	Reporting setup and security boundaries
LICENSE	MIT license for original project material
CHANGELOG.md	Honest release history
.github templates	Reproducible issues and review evidence


Future source directories are described in ARCHITECTURE.md. They should be created when their milestone begins, without placeholder implementations that imply working behavior.
2. Licensing
The initial material uses the included MIT license. This is a proposed default for a project intended to be easy to inspect, modify, and contribute to.
The copyright notice uses “Goal Layer contributors” as the project attribution. Before distributing contributions from an existing entity or importing code, confirm the appropriate attribution and rights. Keep dependency and asset licenses separate. The project license does not relicense external code, fonts, sounds, or model weights.
Create an asset/source inventory as soon as external material is introduced. Prefer original vector artwork and system-provided UI resources used under their applicable terms.
Reference: GitHub's MIT license guide.
3. Initial publication
These commands are instructions for an authenticated developer environment. They have not been run against a remote repository as part of this specification.
Before executing them, inspect the new directory and its contents. Do not run them in an existing unrelated project. Confirm which account the GitHub CLI is using. If the desired repository already exists, inspect its purpose and history rather than overwriting it.
cd goal-layer
git init -b main
git add README.md CODEX_TASK.md AGENTS.md docs examples CONTRIBUTING.md SECURITY.md LICENSE CHANGELOG.md .gitignore .github
git diff --cached --stat
git diff --cached
git commit -m "Define Goal Layer product and implementation plan"
gh auth status
gh repo create goal-layer --public --source=. --remote=origin --push
gh repo view --json nameWithOwner,url,visibility,defaultBranchRef
If an organization is the agreed destination, replace the repository argument with its explicit owner/name.
The GitHub CLI documents creating a repository from local source and pushing it with the flags above. See gh repo create.
Publication acceptance
- The new repository contains only this project.
- Its visibility is verified as public.
- The displayed owner/name matches the intended destination.
- The remote default branch points to the reviewed local commit.
- The LICENSE and documentation render.
- The README clearly says the initial version is a specification.
- No application download or working demonstration is claimed yet.
- The actual repository URL is returned to the user only after verification.
If repository creation is unavailable, prepare the exact bundle and report that the remote creation/push is pending. Do not use an unrelated existing repository as a substitute. The user's request to create a standalone open-source project supplies publication intent; a missing tool is a capability issue, not a reason to invent a successful push.
4. Collaboration after publication
Create milestones matching M0–M7 and small issues tied to their acceptance criteria. Set labels for product, native-ui, domain, ai, context, community, accessibility, and documentation as needed.
Enable GitHub Discussions if it becomes useful for contributor questions. This is the development community, separate from the in-app user communities.
Enable and verify private vulnerability reporting before distributing an application beta. Protect the release branch according to the actual maintainer workflow. Avoid creating review requirements that cannot be satisfied by the project's current team.
Publishing the repository does not authorize invitations, direct messages, promotional announcements, or other outreach.
5. Runtime release requirements
A public source repository can exist before a usable application. A downloadable beta needs additional evidence.
Personal alpha
After M2 passes:
- Document actual Xcode and macOS build requirements.
- Provide a clean local build route.
- Demonstrate the manual goal-to-reward loop.
- Keep demo data separate and clearly labeled.
- State that AI, observation, and community features are planned until implemented.
- Record known native limitations.
Activity-aware personal pilot
After M5 passes:
- Include the model/context evaluation results and their dataset versions.
- Explain exactly which applications, browsers, evidence sources, and OS versions were tested.
- Publish a readable data-flow and retention description.
- Demonstrate denied permissions, pause, offline behavior, and data export/deletion.
- Report measured app CPU, memory, UI latency, and optional provider cost separately.
- Use participants' consent for research data and recordings.
Complete public beta
After M6 and M7 pass:
- A clean contributor machine can build the app from the tagged source.
- Public downloads use a documented signing and notarization route.
- Release notes identify supported OS/hardware and known limitations.
- Archive hashes and source commit identity are published.
- The optional community service can be self-hosted with documented migrations, configuration, and backup/restore procedures.
- No personal-use feature requires the project's own hosted service.
- Security reporting and moderation routes work.
- Community account deletion and shared-score correction are demonstrated.
- Dependencies and asset licenses have an inventory.
- Versioned schema and scoring migrations have been exercised on representative data.
Do not invent a signing identity or ship with credentials committed. If the distribution identity is unavailable, report the binary-release gate as pending while keeping the source build available.
Do not add an automatic updater until its signed-update and failure behavior has its own tested acceptance criteria. Manual signed releases are sufficient for the first beta.
6. Release evidence record
For each release, record:
- Source commit and tag.
- Actual build toolchain.
- Tested OS and hardware.
- Reproducible build commands and checks.
- Signed artifact names and hashes, when applicable.
- Evaluation dataset and policy versions.
- Known failures and unsupported environments.
- Data schema migration and rollback considerations.
- Public repository and release URLs after they exist.
An implementation milestone is not complete merely because a repository, screenshot, or installer exists.
