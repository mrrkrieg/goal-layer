# Codex assignment
Mission
Build a standalone, open-source macOS application that makes everyday laptop use more engaging by turning meaningful progress toward user-selected goals into a persistent visual game.
The app lives at the top of the screen as a small, elegant overlay. The user can click it to open their current goal, next quest, character, miniature world, progress history, and community. AI helps the user define goals, break them into actionable quests, understand permitted activity, and identify possible progress. Completing accepted quests earns transparent points and changes the world. Community members can talk, share selected progress, and join leaderboards governed by shared challenge rules.
The user has selected Mac first. Deliver a native Mac experience before planning Windows support.
Current repository status: documentation and implementation specification only. No app behavior, tests, native compatibility, hosted service, or public release has been verified yet.
Read before implementation
Read these files in order:
1. AGENTS.md
2. docs/PRODUCT_SPEC.md
3. docs/UX_SPEC.md
4. docs/SCORING.md
5. docs/ARCHITECTURE.md
6. docs/ROADMAP.md
7. docs/OPEN_SOURCE.md
The roadmap owns milestone IDs and acceptance gates. The scoring document owns reward semantics. The UX document owns the interaction contract. If a real conflict remains, record the decision and resolve it before implementing dependent behavior.
What a successful product does
A new user can:
1. Open the app and immediately understand the companion.
2. Choose or manually define a goal.
3. Approve its completion criteria and a practical first quest.
4. Work in their existing applications.
5. Confirm a completed quest or review evidence that supports completion.
6. See the correct XP and a lasting change in their miniature world.
7. Understand why the reward happened.
8. Return to work without losing focus or managing a dashboard.
9. Optionally share an achievement, ask for help, and participate in a common-rule challenge.
The full product should support professional, learning, creative, and personal goals. Initial fixtures can focus on building a small tool and learning a skill, but do not hardcode the application around a single industry, profession, or workflow.
The core product loop
Goal → approved milestone → quest → work in existing apps → evidence or user confirmation → completion decision → deterministic reward → world change → next action.
AI may propose a goal or a completion. It does not silently activate a plan, change a deadline, award arbitrary points, or publish anything to a community.
Activity context may suggest what the user is doing. Context alone does not demonstrate that an outcome happened.
Desktop experience
Use SwiftUI for views and AppKit for the native window shell. Start with a borderless, nonactivating NSPanel, an accessory app, and a recoverable menu bar item. Use public system APIs.
Default collapsed surface: roughly 300 × 36 points, centered just below the menu bar and camera safe area on the selected display. Expanded surface: approximately 460 × 560 points, constrained to the current usable screen. Respect display scaling and accessibility preferences.
The pill shows the companion, active quest or goal, and concise progress. Clicking expands it. Escape and outside click dismiss it. Passive awards do not take keyboard focus. Long editing and conversations may open a conventional app window.
Implement one polished original visual direction: a miniature floating observatory that develops as the user completes meaningful work. Use 2D rendering and a small number of original assets. A quest may light a path or bring the companion to a workbench; a milestone adds a structure; a completed goal leaves a named landmark linked to the achievement.
The game must have persistent visible consequences. A points badge and a transient confetti animation alone do not meet this brief.
Give the user a small playable build interaction: each milestone unlocks one structure with two cosmetic variants. They can preview and place it in the observatory in five to ten seconds, with an accessible button path and an automatic default if skipped. Save these choices. Placement never changes the earned XP or blocks the next work action.
Reward rules
Follow docs/SCORING.md exactly for the first policy:
- Default milestone budget: 200 personal XP.
- Allocate 160 XP across its approved quests and reserve 40 XP for milestone completion.
- Quest values are fixed before work starts.
- Splitting a quest redistributes its remaining allocation.
- Level = 1 + floor(net personal XP / 200).
- User-confirmed, artifact-backed, and source-confirmed completions keep their evidence labels.
- Browsing, typing, opening apps, asking questions, and time online do not independently award XP.
- AI inference alone never creates a completion award.
- Replaying the same evidence, retrying a request, or reopening the same quest never creates extra eligible XP.
- Corrections use linked reversals; historical transactions are not silently rewritten.
- Goal outcome metrics do not increase simply because XP increases.
- Breaks and missed days do not remove earned progress.
Personal XP is a cosmetic progression system. Community leaderboard points follow a separate published challenge policy. Do not rank arbitrary user-generated goals as if their difficulty or value were equivalent.
AI and observation
Manual operation is a complete supported mode. No model credentials or observation permissions are needed for the local goal-to-reward loop.
Provide a strict model adapter. AI planning returns a typed draft. AI assessment returns a quest reference, evidence references, supported/unsupported criteria, a recommendation, and a short explanation. It never writes the ledger or has tool authority.
Treat browser text, document excerpts, OCR, and community messages as untrusted content. They cannot change observation scope, model instructions, scoring policy, or sharing settings.
Implement optional observation in narrow steps:
- Active application identity during an explicitly started work session.
- Browser evidence submitted through an extension action.
- Separately approved background browser context on allowlisted origins during a session.
- A narrow source verifier.
- Optional selected screen capture and local OCR only after the context pipeline is reliable.
Observation should reduce administration. Do not ask the user to justify every action. Batch progress suggestions, respect quiet mode, and keep the next action visible.
Pause must stop new collection and prevent queued unsent content from leaving. An already transmitted request cannot be recalled; ignore its stale result after pause and disclose what was sent. Do not claim that pausing a local app deletes data already received by an external provider.
Architecture and scope
Use the proposed architecture unless the native spike reveals a concrete reason to change it:
- SwiftUI/AppKit Mac app.
- Pure Swift domain and scoring packages.
- SQLite with transactional, idempotent rewards.
- Keychain for credentials.
- Provider-neutral AI adapter and deterministic fixtures.
- Optional Chrome extension and native messaging host.
- Optional TypeScript community service and PostgreSQL at the community milestone.
- No required hosted dependency for personal use.
A web prototype can support design work, but it does not prove focus behavior, Spaces support, notch placement, permissions, or resource usage. Never mark a native criterion passed from Linux or from browser-only screenshots.
Build sequence
Implement the roadmap in dependency order:
- M0: Establish the isolated project, pin toolchains, resolve native support decisions, and make the next task clear.
- M1: Prove the native overlay's interaction, placement, focus behavior, and resource budget.
- M2: Deliver the complete local manual goal-to-reward loop, persistent world, and correct ledger.
- M3: Add AI goal planning and evidence-aware progress suggestions with fixed evaluations.
- M4: Add optional activity and browser context that improves suggestions.
- M5: Add one narrow evidence verifier, harden the game experience, and run a personal-use pilot.
- M6: Add a small invite community, text conversation, progress sharing, and challenge-specific scoring.
- M7: Publish a documented open-source beta and reproducible release artifacts after all claimed gates pass.
M2 is the first useful personal version. M5 is the first activity-aware personal pilot. M7 is the complete public beta with the requested community.
Do not wait for every future feature to exist before demonstrating a useful slice. Do not skip the native spike in order to build a broad backend first.
Acceptance and reporting
For each milestone:
1. Implement the smallest complete behavior.
2. Run the relevant objective checks.
3. Record a short native demonstration where the behavior is visual.
4. Record the exact command, OS/device, result, and any unsupported condition.
5. Update the milestone status and known limitations.
6. Continue to the next authorized milestone when the current gate passes.
Keep a milestone incomplete when a material gate fails. Fix the failure or record the true blocker; do not lower a criterion merely to claim completion.
At each handoff, report what changed, what the user can do, evidence of correctness, and the next incomplete milestone. Do not stop after writing a plan or a decorative shell when implementation is the active assignment.
Proposed user-study and performance thresholds in this repository are targets. They become results only after measurement.
Open-source delivery
Keep the project in its own repository, provisionally named goal-layer. Use the included MIT license for original project material. Keep external asset and dependency notices intact.
The repository must contain only this project, synthetic examples, and public research references. Do not copy company code, private accounts, browsing records, customer data, keys, or personal documents into it.
When authenticated repository creation is available and the destination account is clear, create the separate public repository and push the reviewed project. The user's request authorizes publishing this standalone project; routine commits and push operations do not need repeated confirmation. If the environment lacks repository creation, prepare the exact files and publish instructions and report that limitation without claiming a live repository exists. If the only remaining route requires a separately authorized browser fallback, obtain that specific authorization.
Do not send messages, invitations, or announcements to other people as part of publishing. Do not modify an existing unrelated repository to compensate for missing creation access.
The final repository should let another contributor understand the product, run its documented local mode, inspect the scoring, and work on the next milestone without access to private infrastructure.
