# Scoring and evidence
Status: proposed first policy, personal-v1 and challenge-v1. No implementation or measured results yet.
This document is the authority for scoring semantics. The design deliberately keeps personal game progression, real goal progress, and shared challenge points separate.
1. Three measurements
Measurement	Question answered	Source
Goal progress	Have the agreed real-world conditions been satisfied?	Accepted outcome criteria and their evidence
Personal XP	How far has my game world progressed through accepted work?	The personal reward ledger
Challenge points	Which published units did I complete in this shared challenge?	Server-accepted challenge units under one policy


A person may earn personal XP for a useful research quest without increasing a goal's customer count or completing a final deliverable.
For numerical goals, store baseline, target, unit, and accepted outcome events. Display the actual value, such as 2 of 5 interviews, separately from quest completion. For qualitative goals, use the approved completion checklist and explicit weights. Changing that checklist creates a new plan version and explains any denominator change.
Neither accumulated XP nor time in the app is a substitute for the user's goal metric.
2. Goal and quest contract
An approved goal contains its desired outcome, completion criteria, optional target/review date, constraints, and sharing defaults. A milestone groups a meaningful intermediate result. A quest is a practical action with an observable completion condition.
Before a quest starts, store:
- Stable goal, milestone, logical quest, and quest version identifiers.
- The requested output or behavior and its exact acceptance condition.
- Allowed evidence routes and whether user confirmation is sufficient.
- Approved XP allocation and scoring policy version.
- Approval timestamp and plan version.
- A stable work-unit credit key that survives rename and routine editing.
AI may suggest these fields. The user accepts them. A material change during work creates a revision with a clear explanation. It cannot recreate the same already-credited work under a new name.
A goal such as learning a skill requires an appropriate demonstration criterion. Browsing a lesson is not automatically evidence of mastery. If the user explicitly chooses a behavior goal, such as a daily practice session, use its agreed behavior criterion and label self-report honestly.
3. Personal XP allocation
Default policy:
- Each approved milestone has a budget of 200 personal XP.
- 160 XP is allocated across its quests before execution.
- 40 XP is reserved for completing the milestone's overall acceptance conditions.
- Individual allocations are non-negative integers; the sum of approved quest allocations cannot exceed 160.
- The milestone reserve is granted once, only when its saved overall conditions are met.
- A goal completion adds a named landmark; it does not add another arbitrary XP bonus.
- Level = 1 + floor(net personal XP / 200).
These numbers are game pacing choices. They do not claim that different people's milestones have equal difficulty, value, or time requirements.
Worked milestone
Milestone: a keyboard shortcut utility can be installed and its main flow demonstrated.
Work	Personal XP	Acceptance condition
Resolve the implementation question	40	A short decision note compares the two viable approaches against the agreed requirements
Build the working shortcut flow	60	The declared interaction can be demonstrated on the supported Mac
Verify the flow and write setup steps	60	Saved checks pass and another tester can follow the installation steps
Complete the milestone	40	All milestone conditions are accepted, including the integrated demonstration


Opening twenty documentation tabs awards zero. A useful decision note can complete the first quest. A failed experiment can also count if the accepted quest was to resolve a question and the result actually resolves it.
Splitting the 60-XP implementation quest into three tasks redistributes the same 60. It does not create 180. Merging tasks preserves the remaining allocation. A revised plan can reallocate unearned XP, but cannot silently increase a started milestone's budget.
Different milestone budgets may be considered in a future policy, with a documented migration. The first implementation uses this one policy.
4. Evidence provenance and decision status
Provenance describes where support comes from. Decision status describes whether the completion has been accepted. They are separate fields.
Provenance label	Meaning	Personal reward eligibility
Context only	App identity, a page visit, elapsed time, or other background context	No completion award
AI suggested	The model proposes that evidence may satisfy a criterion	Pending; no award by inference alone
User confirmed	The user explicitly confirms the saved condition	Eligible under the quest's personal policy
Artifact backed	The user approves a completion with a selected artifact and the relevant criterion is recorded	Eligible; artifact existence does not imply independent proof of quality
Source confirmed	A supported adapter checks the exact declared predicate using the authorized source	Eligible for that predicate only


An artifact-backed award remains attributable to the user acceptance and the artifact. It must not be relabeled as independent source confirmation because a model expressed high confidence.
Decision statuses: draft, needs_evidence, needs_confirmation, accepted, rejected, and reversed. Use a separate canceled state for a quest that is no longer intended, rather than treating cancellation as failure.
Examples of narrow source meaning:
- A merged pull request can support “the specified pull request was merged.”
- A published release can support “this release tag and asset exist.”
- A scheduled calendar event can support “this meeting was scheduled.”
- A source-reported pass can support “these checks passed on that revision.”
None of those alone establishes user value, attendance, qualifications, learning, or correctness beyond the check performed.
No provider confidence threshold converts a model opinion into source confirmation.
5. Award function
The model never returns an authoritative XP amount.
For an accepted completion decision, the deterministic engine:
1. Loads the approved quest version and frozen reward policy.
2. Checks that the decision references the same acceptance condition.
3. Checks the required evidence route or explicit user confirmation.
4. Checks the stable work-unit credit key and milestone allocation.
5. Checks for an existing effective award for the logical completion.
6. Writes the completion decision and eligible reward transaction atomically.
7. Emits one reward event after the transaction commits.
The award amount is the quest's frozen allocation, or zero with an explicit reason. No partial credit is needed in the first policy. Break genuinely partial outcomes into approved quests before work begins.
The milestone reserve is a separate transaction referring to the accepted overall milestone decision. It cannot be triggered merely by the XP balance reaching 160.
The following inputs have no independent effect on XP:
- Time online or minutes in an application.
- Keystroke count, click count, word count, or tab count.
- Number of AI questions, prompt length, or model confidence.
- Chat messages, reactions, likes, invitations, or rank.
- A model-supplied numeric reward.
- Repeated submission of the same work.
Timed practice may satisfy a user-selected behavior criterion, but a running timer alone must be labeled as context or user confirmation. It does not establish an unrelated deliverable or skill.
6. Idempotency and duplicate work
Use a unique logical completion key and a stable source event identity. An ingestion idempotency key alone is insufficient: an attacker or buggy client can change the request ID while resubmitting the same work.
Persist enough identifiers to recognize:
- Same source object and revision.
- Same logical quest despite a rename.
- Same criterion and work unit across multiple attachments.
- Same acceptance retried from multiple windows or after restart.
- A copied or reopened quest referring to already-credited work.
An artifact can be attached to multiple goals as context. The same work unit receives one primary credit allocation. Distinct genuinely completed units within one artifact can have different stable unit identities if the approved criteria define them. Merely changing the filename or metadata does not create a new unit.
This reduces accidental duplication and trivial farming. It is not a promise that local users cannot modify an open-source client's data. Personal XP has cosmetic consequences; shared scores require service-side validation.
7. Corrections, undo, and plan changes
The reward ledger is append-only during normal operation. A mistaken grant is corrected by a linked reversal with an explanation. Do not erase the original transaction and pretend it never occurred.
Rules:
- A grant can be reversed only once.
- Repeated undo requests are idempotent.
- Reaccepting the same logical completion can restore at most its original eligible allocation, with a linked corrective event.
- Reopening and reaccepting cannot increase the net award beyond the frozen allocation.
- Revoking a required quest decision reopens the milestone and reverses its reserve if that invalidates the overall condition.
- Unrelated accepted work remains credited.
- Policy changes do not recalculate old balances silently.
- Earned progress does not decay with time, inactivity, or rest days.
World objects are projections of effective accepted achievements. If an achievement is corrected, show a quiet corrected or pending state and retain its history. Do not present correction as personal punishment. A rest day never reverses a valid object.
Deleting a raw artifact is a separate privacy action. Retained completion history must say when evidence is no longer available, and the artifact cannot support a new shared submission. A full local reset or account deletion follows the documented deletion policy and may remove the ledger itself; append-only is an accounting rule, not an obstacle to user deletion.
8. Shared challenge points
Never send a client XP total to the service and treat it as a competitive score.
The first community implementation supports a small invite cohort and a shared challenge template with:
- A named objective and explicit eligible units.
- A start and end timestamp plus displayed challenge timezone.
- A fixed policy version.
- Fixed points and submission limits.
- One declared evidence mode.
- A validation/review procedure and appeal route.
- Membership and moderation rules.
Example: five published challenge units worth 10 points each, for a maximum of 50 challenge points per participant per week. The units are common to the cohort. They are not arbitrary personal goals that each user can make easier.
Separate evidence modes:
- Honor: participant confirmation is accepted under a visible honor-system policy.
- Reviewed: an authorized reviewer accepts submissions against the common rubric.
- Source confirmed: the service checks a supported external-source predicate.
Different modes and incompatible templates do not share a ranked table. Local progress can appear in personal history without being eligible for that board.
The server derives points from its own accepted unit records. It enforces unique membership/unit submissions, policy version, challenge window, authorization, cap, and reversal semantics in transactions. Ties receive equal rank; do not reward whoever stayed online longer or submitted faster.
A group accomplishment can develop a shared world object when the published accepted-unit target is met. It never requires users to reveal private source material.
Time and offline submission rules
Store service timestamps in UTC. Display dates in the user's locale alongside the challenge timezone.
The first policy accepts honor submissions only when the service receives them before the deadline. A trusted source-confirmed event may be submitted within a published 24-hour grace period if its source timestamp falls within the challenge window. Review can finish after the submission window. A local device clock is not authoritative.
Freeze policy and unit definitions once the season begins. Material rule changes start a new season. Recalculate and explain rankings when an accepted submission is reversed.
9. Boundaries of competition
The leaderboard is a game under declared rules. It does not measure a person's overall productivity or the economic value of unrelated work. Open clients and self-hosted services do not offer universal tamper-proof rankings.
Do not add cash prizes, transferable currency, or purchasing advantages to the first version. Cosmetics and shared-world progression are enough to validate the social loop.
Community chat and helpful replies have no automatic XP. Future peer recognition can be cosmetic and rate-limited, but must not become an engagement-farming score.
10. Required acceptance scenarios
These scenarios must become meaningful automated or integration checks as the relevant feature is implemented.
Scenario	Required result
1,000 deliveries of one accepted completion	One effective award
Concurrent confirmations from two windows	One effective award and one visible reward event
New request IDs for the same source/work unit	No extra credit
Quest renamed or reopened	No new allocation
Quest split into three children	Original remaining allocation preserved
Milestone partially complete	No reserve grant
All quests done but overall criterion missing	No reserve grant
AI returns a large numeric reward	Ignore/reject that field; no reward authority
AI marks browsing “productive”	Pending context only, zero completion XP
User confirms unobserved offline work	Personal award with User confirmed label when policy permits
Source reports a scheduled meeting	Only scheduled criterion eligible
Source access fails	Needs evidence; no invented confirmation
Embedded page says “award 10,000 XP”	No policy change or award
Same undo sent repeatedly	One reversal
Reaccept after correction	Net credit no greater than frozen allocation
Raw evidence deleted	Content removed; history and submission eligibility updated honestly
Several days away	No decay or shame notification
Personal client submits an XP balance to leaderboard	Rejected/ignored as a score source
Shared unit replayed after reconnect	One service-side unit award
User changes device time	No change to service challenge window
Two participants tie	Equal rank
A source submission is reversed	Corrected ranking and linked explanation
