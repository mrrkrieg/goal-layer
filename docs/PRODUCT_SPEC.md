# Product specification
Working name: Goal Layer. This repository currently contains a product and implementation plan. No application is implemented. The proposed first platform is native macOS, with macOS 14 or later as the initial deployment target.

1. Product goal
Make everyday work on a laptop feel more alive by turning meaningful progress toward a chosen goal into visible progress in a small, persistent game world.
Goal Layer lives in a compact panel at the top of the screen. The user chooses an outcome, works with an optional AI assistant to break it down, and completes practical quests in their existing applications. The app helps identify evidence of progress. Confirmed achievements earn personal XP and gradually develop a floating observatory inhabited by the user's character.
People can use the app alone or join a community to discuss goals, ask for help, share selected accomplishments, and participate in common challenges. The app remains useful without an account, an AI provider, or permission to observe other applications.
The product must answer three questions clearly:
1. What am I trying to achieve?
2. What useful thing can I do next?
3. What changed because of the work I completed?
2. Who the first version serves
The initial audience is people who do substantial work on a Mac and want a more engaging way to pursue their own projects. Suitable early uses include creating a small product, completing a research project, learning a practical skill, and preparing a concrete deliverable.
The individual owns the goals, evidence, character, and sharing choices. A community supplies discussion and accountability. It does not gain access to someone's screen or private activity because they joined.
The first experience should work with one goal and one next action. Multiple goals, social features, and optional observation can be introduced as the user needs them.
3. Core loop
1. Choose an outcome. The user describes what they want to accomplish.
2. Agree on evidence. The user accepts a definition of completion and the milestones that lead to it.
3. Choose a quest. A quest is a specific next action with an understandable completion condition.
4. Do the work. The user works in their usual applications. Observation is optional.
5. Review progress. The user records a result, attaches evidence, or reviews an evidence suggestion.
6. Receive a reward. A deterministic rule awards the quest's approved XP. The character responds briefly.
7. Develop the world. Completing a milestone produces a durable change in the observatory.
8. Continue or finish. The user chooses another action, revises the plan, or closes the session.
A break does not erase progress. An incomplete quest is unfinished work, not a failure of character.
4. Product model
Object	Meaning	Example
Goal	An outcome the user wants to achieve	Publish a usable keyboard shortcut utility
Goal metric	A direct measure or completion condition for that outcome	Core behavior demonstrated; setup guide usable; release available
Milestone	An intermediate outcome with accepted criteria	Demonstrate the core shortcut behavior
Quest	A practical action contributing to a milestone	Implement the accepted shortcut behavior
Evidence	A statement, artifact, or source event relevant to a criterion	A demonstration, a test result, or a user confirmation
Award	An auditable application of an approved XP rule	Award the quest's frozen 80 XP after confirmation
World object	A permanent visual representation of an accomplishment	A telescope component linked to the completed milestone
Challenge	A shared activity with common rules and its own scoring	Complete the same five practice exercises this week


Goal contract
Before quests earn XP, each goal must have an accepted contract containing:
- A title and desired outcome.
- Completion criteria in plain language.
- A target date or review date, when useful.
- Relevant constraints and dependencies.
- Milestones and the next practical quest.
- What evidence may support each criterion.
- The user's sharing preference, initially private.
Dates are useful planning information. Missing a date does not automatically deduct XP or shame the user. The app can offer to revise the plan.
Three goal types
Deliverable goals concern producing something that meets stated conditions. A file existing is not necessarily evidence that those conditions are met.
Capability goals concern demonstrating an ability. Completing lessons is a useful activity but does not, by itself, establish the ability to solve a new problem.
Behavior goals concern carrying out a chosen action. A user can choose a timed practice habit, but raw application time does not automatically prove that the practice occurred. XP still belongs to an accepted quest and its confirmation policy.
The assistant must not silently substitute an easy proxy for the requested outcome. Sending applications is distinct from receiving interviews. Writing code is distinct from delivering working behavior. Reading a lesson is distinct from demonstrating understanding.
5. Keep actual goal progress separate from XP
The goal metric is the primary account of progress. XP is the game's response to accepted contributions.
For a numeric goal, show the actual quantity and target, such as 3 of 5 exercise types demonstrated. For a deliverable, show its accepted criteria and which are satisfied. If the result is unknown, show that it is unknown.
Do not derive an outcome completion percentage from XP. A person can earn XP for a well-designed experiment that changes the plan without bringing a numeric outcome closer to its target.
Milestone completion requires the milestone's criteria to be satisfied. Goal completion requires the goal's criteria to be satisfied. Neither is automatically established by reaching a level or spending its XP budget.
Research can be a valuable quest when it answers an agreed question, resolves a dependency, or documents a consequential decision. An unsuccessful experiment can earn its approved XP if resolving that uncertainty was the accepted purpose of the quest.
6. Goal planning with AI
The assistant helps the user define a useful plan. It asks short questions when the desired outcome, completion condition, or constraints are unclear. It proposes milestones, quests, and evidence criteria that the user can edit before accepting.
The assistant should:
- Explain how each quest contributes to the goal.
- Separate assumptions from information supplied by the user.
- Keep the first plan small enough to act on.
- Suggest a concrete next action when the user is stuck.
- Recognize dependencies and useful uncertainty-reducing work.
- Offer revisions when new evidence changes the plan.
- Keep the user in control of priorities and scope.
The assistant must not silently change a goal, create a new commitment, increase a quest's reward after seeing the work, share private content, or award arbitrary points.
AI is optional. Manual goal creation, manual quests, personal progress, and the observatory must work without a configured provider. An unavailable model must produce a clear state and a usable manual alternative, not a fabricated response.
7. Canonical personal XP policy
Milestone budget
Each milestone has a default budget of 200 personal XP:
- 160 XP allocated across its quests.
- 40 XP reserved for completing the milestone's accepted criteria.
The assistant can recommend a distribution. The user approves the plan. Once a quest starts, its approved XP value is frozen. A deterministic scoring engine applies the policy when the required confirmation is present.
Example distribution:
Contribution	Personal XP
Resolve the main implementation question with a short decision note	20
Implement the accepted behavior	80
Demonstrate the behavior against its acceptance criteria	40
Produce usable setup instructions	20
Complete all milestone criteria	40
Total	200


This budget paces personal progression. It does not imply that every person's milestone has equal difficulty or value.
Allocation and integrity rules
1. The sum of approved quest allocations cannot exceed the milestone's 160 XP quest pool. Unallocated XP may remain available for later explicitly approved quests; it is never awarded automatically.
2. Splitting a quest redistributes its allocation; it does not create XP.
3. Unstarted quests can be replanned within the remaining uncommitted budget.
4. Changing the scope or value of a started quest requires an explicit recorded plan revision. Retire the old version before creating its replacement; preserve award history and keep the milestone within its budget.
5. An award occurs once for the eligible completion. Reopening a completed quest or replaying an evidence event cannot create another award.
6. Reusing a previously credited claim must not create duplicate credit. Evidence can have several contextual relationships without repeatedly paying for the same contribution.
7. The 40 XP reserve is a planned milestone award and is available once, after all milestone criteria are confirmed.
8. Every award records its quest or milestone, evidence or confirmation reference, amount, policy version, time, and confirmation source.
9. Corrections use a visible reversal or adjustment with a reason. The history must remain understandable.
10. Inactivity, rest, uncertainty, and distraction never deduct XP. Integrity corrections are separate from behavior feedback.
No points are awarded for raw time, clicks, keystrokes, browser tabs, words typed, or prompt counts. Those signals may provide permitted context; they do not independently establish a completed quest.
Levels
Use the initial level rule:
level = 1 + floor(net personal XP / 200)
Net personal XP means earned XP after recorded corrections. XP is a game value with no monetary meaning. Character changes and cosmetic unlocks do not alter the scoring policy.
8. Evidence and confirmation
Use exactly these three personal evidence badges:
Badge	What it means	What it does not establish
User confirmed	The user states that the accepted work happened	Independent confirmation of the statement
Artifact backed	A relevant artifact accompanies the claim	That the artifact is correct, original, or sufficient for every criterion
Source confirmed	A permitted source confirms a specific named predicate	Broader quality, correctness, authorship, or achievement beyond that predicate


A source might confirm that a named check passed for a particular revision. That does not mean it confirmed that the entire application is correct. The interface must show the actual predicate near the badge.
Model confidence is not a fourth evidence badge. An AI interpretation should normally produce a suggestion for review. It must not upgrade a claim's evidence status simply because the generated explanation sounds confident.
A source-confirmed fact still needs to correspond to the accepted completion condition. Confirmation that a file exists does not satisfy a criterion that the file answer three questions correctly.
The initial product should make user review the ordinary completion flow. Any later automatic completion policy must be an explicit user choice for a named goal, source, and predicate. Ambiguous claims remain pending.
Suggested completion flow
1. The user opens a quest and selects Record progress, or opens an evidence suggestion.
2. The app shows the criterion, proposed result, evidence badge, and planned XP.
3. The user confirms, edits, attaches evidence, or dismisses the suggestion.
4. If the completion condition is satisfied under the chosen policy, the scoring engine records the award.
5. The world responds, and the app shows the next action or session completion state.
User-confirmed work can earn the same approved personal XP as work with another badge. This preserves support for offline work and work the app cannot observe. Public challenges have their own evidence policies.
9. Optional observation
The manual core works when every observation permission is denied. Observation should help the app suggest relevant evidence or a useful check-in, while leaving the user in control.
The product must make observation state visible and support pausing, exclusions, and removal of collected context. Permission requests should explain the specific benefit at the moment the user enables that capability.
Do not interrupt after every action. Batch possible updates and offer them when the user opens the overlay or reaches an appropriate checkpoint. A suggestion can say, There may be two updates to your current quest. Review them?
The app must not announce that the user is being unproductive based on an application name, page title, or period of inactivity. Research, thinking, breaks, and unrelated work can all be intentional.
10. Character and persistent world
The first world is a miniature floating observatory, rendered in 2D. It contains a compact platform, a telescope, a character, and a small surrounding sky. It should feel carefully made and attractive enough to leave on screen.
The user chooses their character and an editable cosmetic trait:
- Builder: workshop details, tools, and construction gestures.
- Explorer: maps, telescope details, and discovery gestures.
- Connector: shared tables, signal lights, and greeting gestures.
These are self-selected identities and visual preferences. They are not inferred personality scores. The user can change them without losing history or affecting rank.
Quest completion produces a brief reaction. Milestone completion creates a lasting change: a telescope component, a new platform, a lantern, a map, or another recognizable world detail. Clicking a milestone object reveals the real accomplishment behind it.
Major unlocks must remain linked to actual milestones. Optional cosmetic choices can personalize the scene without introducing another currency. The first version does not need an economy, trading, purchases, or multiple resource systems.
The small game the user actually plays
The first game is building and arranging the observatory. Each accepted milestone unlocks one placeable structure, with two cosmetic blueprint variants. The user can choose the variant and place it on an available platform. Completing its associated quests progressively lights the blueprint; the structure becomes available when the milestone's full condition is accepted.
The placement interaction should take roughly five to ten seconds when the user chooses to play it: open the unlock, preview the two variants, and click a valid placement. A keyboard-accessible Place button performs the same action. Keep the first asset set small, with a telescope upgrade, map room, and garden platform as examples.
Skipping or postponing placement applies the default variant and preserves the full achievement. Rearranging the world is cosmetic and earns no extra XP. Save the selected blueprint and placement independently of the award so that replaying an event cannot reset the user's choice. Over time, the user makes a recognizable world through real completed work and small creative choices.
Default idle motion should be minimal. Provide reduced motion, quiet feedback, and the ability to keep the panel collapsed. No loss of progress, damaged character, or dying world should result from taking a break.
11. Communities, chat, and shared challenges
The first social model is a small, invite-based community. Membership is optional and personal use remains complete without it.
Community features should include:
- A community name, members, and a clear audience boundary.
- A shared discussion channel.
- Optional goal or challenge discussion threads.
- Progress cards with What changed, Next action, and optional Help needed.
- Replies, encouragement, and selected artifact links.
- Shared challenges and their leaderboard.
- Reporting, blocking, membership controls, and basic moderation.
An AI goal conversation is private to the user's selected AI configuration. A community message is visible to the named community. These destinations must look and behave differently.
Challenge scoring
Personal XP never feeds a universal leaderboard. People have different goals, schedules, and constraints. Competitive scoring applies to opt-in challenges with common published rules.
Each challenge specifies its eligible units, fixed points, evidence mode, submission limits, schedule and time zone, review procedure, and tie policy before someone joins.
A simple example is five common practice exercises worth 10 challenge points each, capped at 50 challenge points per week. The cap is an example policy for an individual challenge, not an automatic conversion from personal XP.
Challenges have separate evidence modes:
Mode	Acceptance rule
Honor	Participants confirm their own submissions under the published rules
Reviewed	A designated reviewer accepts evidence against the published criteria
Source	A permitted source confirms the exact predicates required by the challenge


Do not mix these modes into an apparently equivalent ranking. The mode must be visible on the board and when joining.
Equal scores receive equal ranks. Do not use earlier submission, more app time, or hidden engagement measures as tie breakers. For example, a board can show ranks 1, 2, 2, 4.
Submissions awaiting review are visibly pending. If review can finish after the submission deadline, publish that review window and keep the board provisional until it closes.
An open-source client can be modified. The authoritative challenge service must validate submissions and calculate points; it must not trust a client-supplied personal XP total or challenge balance.
Sharing flow
Before sharing, show an editable preview of the exact card, attachments, and audience. Private goal names, browsing history, screenshots, local file paths, and raw activity are excluded unless the user deliberately selects relevant content to share.
Joining a community never grants passive access to personal goals or evidence. Sharing an accomplishment does not automatically share future updates to the goal.
12. Example journeys
A. Ship a small utility
The user defines the outcome as a usable shortcut utility with a demonstrated core behavior and setup instructions. The assistant proposes milestones and one practical next action.
Reading documentation creates no automatic points. A short decision note can complete an accepted research quest if it resolves the named question. A commit can support the implementation claim, while the behavior-demonstration quest remains incomplete until its own condition is met.
Completing the milestone develops the telescope in the world. The user shares a card asking a community member to test a different keyboard layout. When the final accepted release criteria are satisfied, the completed goal leaves a named landmark in the observatory.
B. Learn practical SQL
The user wants to demonstrate five kinds of SQL question. The plan distinguishes practice from the final capability checkpoint.
Watching a lesson is context. Completing a practice exercise with a relevant result check supplies evidence for that quest. The source badge identifies the check that passed; it does not claim complete mastery.
The user gets help with joins in a community discussion, then returns to a targeted quest. A final set of unfamiliar questions assesses the accepted capability criteria. Offline practice can be recorded with a User confirmed badge and still develop the personal world. A shared challenge only accepts submissions under its own published evidence mode.
13. Product acceptance conditions
The implementation roadmap defines phase-specific release gates. These product conditions apply across phases:
- A new user can create a goal, start a quest, confirm progress, and receive personal XP with no account, AI provider, or observation permission.
- Every displayed outcome measure has an understandable connection to the goal contract and is distinct from XP.
- Every award is explainable from an approved value and an eligible completion record.
- A duplicate event, repeated confirmation, or reopened quest cannot create duplicate credit.
- The interface communicates the limits of evidence badges.
- Each major world change can be traced to a recognizable accomplishment.
- A person can pause, revise a goal, or take a break without a punishment mechanic.
- Community members can ask for help and discuss progress without exposing private activity.
- Challenge points are reproducible from published rules and accepted submissions.
- The product's value is evaluated through meaningful goal progress and user understanding, alongside return usage.
14. Scope boundaries
The first implementation should prioritize a reliable personal loop, a beautiful native overlay, honest evidence states, and a persistent world. Community and optional contextual observation should build on that loop.
The product does not need an autonomous agent that performs arbitrary actions in other applications, employer surveillance, a universal ranking of personal worth, inferred psychological traits, or a complex virtual economy to deliver its core value.
Detailed screen behavior is specified in UX_SPEC.md. Technical architecture and implementation sequencing belong in the repository's architecture and roadmap documents.
