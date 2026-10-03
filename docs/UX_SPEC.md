# Experience and visual specification
This is a design target for a future native macOS application. The current repository is documentation only. The proposed first deployment target is macOS 14 or later.

1. Experience direction
Goal Layer should feel like a small, beautiful object that belongs on the desktop. It is always easy to reach, gives useful context in a glance, and opens into a miniature world with a practical next action.
The visual character is a floating observatory at dusk: a warm little platform, a precise telescope, a chosen companion, softly lit windows, and a few clear stars. The surrounding interface is calm and highly legible. The world provides personality; the controls remain straightforward.
Avoid filling the interface with competing counters, banners, confetti, badges, and charts. The user's current goal and next action should remain understandable throughout the experience.
2. Surface model
Collapsed top pill
- Default size: 300 × 36 points.
- Position: centered near the top of the primary display by default, or the user's pinned display, below the menu bar and notch safe area. It does not chase the pointer between displays by default.
- Default corner radius: 18 points.
- Keep a small visible gap from the menu bar; never draw through a camera notch or obscure menu items.
- Respect available space on each display rather than treating the notch as a fixed size.
- Allow the user to choose their preferred display and adjust the position within safe bounds.
The pill contains a small character or observatory symbol, a concise current quest label, a meaningful state indicator, and an expansion control. The label can truncate, with its full text available through the expanded view and accessibility description.
Examples of the visible text:
- Choose your first goal
- Demonstrate the shortcut
- 2 updates to review
- Observation paused
XP can briefly appear after an award as +40 XP, then return to the useful working state. A permanent generic progress ring must not imply an outcome is 80% complete simply because 80% of an XP budget was earned.
The pill should be quiet while the user types or reads. It must not take keyboard focus or require interaction to continue using another application.
Expanded panel
- Initial target size: approximately 460 × 560 points.
- Anchor below the pill, maintaining a visible connection between them.
- Use a stable header and navigation area, with a scrollable content region when necessary.
- Keep content inside the display's usable bounds, including on smaller displays and at enlarged text sizes.
- Offer an ordinary resizable window for long planning, larger text, detailed history, and extended community conversations.
Default contents from top to bottom:
1. Header: goal switcher, current state, and settings.
2. World: a miniature observatory scene, approximately 120–140 points high.
3. Goal progress: the outcome and its actual metric or accepted criteria.
4. Current quest: next action, completion condition, planned XP, and one clear primary action.
5. Review area: a small evidence suggestion or recent completion, when one exists.
6. Navigation: Plan, Community, and History.
The world remains visible enough to create an emotional connection. It must not push the next action below the initial viewport in the ordinary state.
Ordinary window
Open the larger window for complex editing and sustained conversation. It should preserve the same goal context and design language. The overlay is a convenient entry point, not a requirement to perform all work in a small popover.
3. Visual system
Use native macOS text rendering, controls, keyboard conventions, and accessibility behavior. Use restrained custom styling around them to give the world and overlay a clear identity.
Suggested initial palette:
Role	Dark appearance	Light appearance
Main surface	#171B26	#F5F3EE
Raised content	#242B39	#FFFFFF
Main text	#F4F3EF	#202630
Secondary text	#AAB3C2	#596171
Mint accent	#A8F0DD	#246F60
Warm reward accent	#D9BE7D	#8A621A


These are starting tokens, subject to contrast verification in the actual implementation. Translucency must preserve readable text on arbitrary desktop backgrounds. Provide a sufficiently opaque backing surface and respect system contrast and transparency preferences.
Use the system font. Suggested default sizes are 13–14 points for the collapsed pill, 14–15 points for ordinary panel text, 17 points for the current quest, and 20–22 points for a main outcome heading. The layout must respond to larger text rather than scaling a screenshot of the interface.
Prefer clear spacing and a small number of surface levels. Do not outline every piece of content as a separate card. Status must always be communicated through text or an icon with a text alternative, not color alone.
4. First minute
The first interaction should lead to useful action without a permission cascade.
0–10 seconds: meet the object
The pill appears with Choose your first goal. Clicking it opens a small observatory with a still companion and the prompt:
What would you like to make progress on?

Provide a text field and a direct manual path. If an AI provider is already configured, offer Plan with AI. Otherwise, make the optional setup available without blocking goal creation.
10–30 seconds: state the outcome
The user enters a goal. Ask what would count as done. Keep the date optional at this point unless it is essential to the goal.
Example:
Publish a working shortcut utility.

Completion condition:
The shortcut works in the demo and someone can follow the setup instructions.

If the user wants AI help, the assistant asks the smallest number of questions needed to produce a usable proposal. Show the proposed plan as editable content with a clear acceptance action.
30–45 seconds: choose the first quest
Show one practical next action with its completion condition and proposed personal XP. Allow the user to edit it.
Decide how the shortcut should behave
Done when: write the input, expected action, and one edge case.
Planned reward: 20 XP.

The first quest must be understandable before it starts. XP rules come from the accepted milestone budget in the product specification.
45–60 seconds: begin
Offer three editable cosmetic traits: Builder, Explorer, and Connector. A default character can be accepted immediately so customization does not block work.
The user chooses Start quest. The companion moves to the telescope, the panel collapses, and the pill shows the next action.
No account or observation permission is required. If planning takes longer because the goal is complex, prioritize clarity over completing onboarding on a stopwatch.
5. The observatory
Initial scene
The starting world is small: a circular platform floating in a dark sky, a simple telescope, one lantern, a few plants or tools, and the chosen companion. It should look intentional before the first reward is earned.
Use a 2D implementation for the first version. Layered illustration, controlled lighting, and small animations can create depth without requiring a 3D environment.
Persistent development
Milestones introduce lasting details:
- A new telescope component.
- A second platform connected by a short walkway.
- An illuminated map table.
- A constellation tied to a completed goal.
- A new room or observatory wing.
The exact asset sequence can evolve. The rule is that each major change has a clear milestone relationship. Selecting a world object opens a short card naming the accomplishment, its date, and its evidence status.
Avoid an infinitely expanding scene that becomes unreadable. Completed goals can occupy separate world views accessible through a small history control. The active world remains compact.
Build interaction
When a milestone finishes, a new structure is ready to place. The next time the user opens the world, show two cosmetic blueprint variants and a preview on the available platform. The person picks a variant and clicks Place; optional drag-to-place may be added after the accessible click path works. The placement snaps into the scene with a brief construction gesture.
This optional five-to-ten-second interaction is the initial playable game. It gives the user a choice in how their observatory develops. It never changes the XP earned, blocks work, or requires reflexes. Use a default placement if skipped, allow later rearrangement, and preserve choices across restarts and corrections. Only accepted milestone unlocks can place new structures; repeated placement does not earn anything.
Begin with three structure families: telescope upgrade, map room, and garden platform, each with two appearance variants. This is a bounded art target, not a requirement for a large world editor.
Traits
Builder, Explorer, and Connector affect the companion, scene details, and gestures. They do not affect scoring, imply inferred personality, or restrict what goals the user can pursue.
Changing a trait changes the presentation without deleting progress. The interface should say Character style or Choose your trait, with a short explanation that the choice is cosmetic.
Rewards
An ordinary quest reward lasts about one second. The companion makes one clear gesture, the scene receives a warm accent, and the earned amount appears briefly. For example, the character installs a small component and +40 XP rises a few points before settling into the history.
A milestone can reveal a larger change in the expanded scene. If the user is working elsewhere, record it and offer See your new observatory detail when they next open the app. Do not force the panel open.
No continuous confetti. No mandatory clicks. No penalty for skipping a celebration. No default sound. Reduced motion replaces movement with a short, readable state change.
6. Goal and quest interactions
Goal summary
Always distinguish the goal metric from game progression.
Example:
Demonstrate five SQL question types
3 of 5 demonstrated
Level 4 · 680 personal XP

The metric uses the goal's accepted criteria. XP is labeled as personal XP. A checklist is preferable to a misleading percentage when the outcome is qualitative.
Current quest
The current quest has:
- A short action title.
- One visible completion condition, with expansion for more detail.
- Its frozen planned reward once started.
- A primary action appropriate to the state.
- Secondary actions for editing, changing the plan, or recording a blocker.
Starting a quest does not begin awarding points with time. If a session timer is offered later, label it as a time aid and keep it separate from XP.
Record progress
The primary completion flow shows:
1. The accepted completion condition.
2. What changed? with a short editable result.
3. Optional evidence selection.
4. The evidence badge and what it means.
5. The exact planned XP.
6. Confirm completion or an explanation of what remains.
For partial progress, save the result without paying the full completion award. Offer to revise or split future work only through the explicit plan-revision flow. Do not silently create additional XP.
Evidence suggestion
Use restrained, specific language:
The named behavior check passed for this revision. Does this complete the demonstration quest?

Show the source-confirmed predicate and the quest criterion next to each other. Actions are Confirm, Review evidence, and Dismiss.
For an ambiguous artifact:
This document may relate to your research quest. Add it as evidence?

The app must not write Goal verified because a model inferred that a file looked relevant.
Dismissed suggestions should stay dismissed for the same event. Users must not repeatedly answer the same question.
Plan changes
Goal editing should explain how the revision affects unfinished quests. Preserve completed work and award history. A started quest's reward cannot be quietly increased after the work has happened.
If an award is corrected, show a clear history entry such as Duplicate award corrected: −20 XP. Do not animate the companion suffering or describe the user as having failed.
7. Private goal assistant
The AI assistant lives inside the planning context. The heading is Goal assistant, and the panel identifies the current goal.
Useful entry actions include:
- Help me define this goal
- What should I do next?
- I am blocked
- Review this evidence
- Revise the plan
AI suggestions that affect a goal appear as a reviewable proposed change. The user accepts or edits them. Ordinary conversation does not silently change the plan.
Before sending selected private material to an AI provider, make the destination and included material understandable. A local-only user can continue with manual planning.
When AI is unavailable, preserve the draft and show The assistant is unavailable. You can keep editing the plan manually. Do not leave the main progress controls disabled.
8. Community and chat
Community home
The Community view shows the current community, members, discussion, active challenges, and selected progress cards. A person without membership sees Join a community and Create a community, alongside a clear way to return to their personal plan.
The community name and audience remain visible while composing. A community chat is visually distinct from the private Goal assistant.
Sharing progress
Share progress opens an editable preview:
What changed
The shortcut now works in the demo.
Next action
Test the alternate keyboard layout.
Help needed
Could someone try this with a different layout?

Below the preview, list the audience and any selected attachments. The user presses Post to [community name] to send it.
Do not include the full private goal, all evidence, local paths, screenshots, or activity history by default. Sharing one card does not subscribe the community to future private updates.
Challenges and leaderboard
Each challenge screen shows its common objective, fixed scoring units, weekly or challenge cap, schedule and time zone, evidence mode, and review policy before the join action.
The board displays challenge points, not personal XP. Honor, Reviewed, and Source modes are visibly distinct. Tied participants share the same rank. Pending submissions are visibly separate from accepted points.
A sample board can be titled SQL practice week, with five exercises worth 10 points each and a 50-point weekly maximum. The label should make clear what earned those points.
Community progress cards can celebrate unlike goals without comparing their difficulty. Keep a universal cross-goal productivity rank out of the interface.
9. Observation and data visibility
The user must understand when context observation is active. Provide a clear state in the expanded header and a concise indication when paused.
Separate these concepts:
- Quest state: whether a task is planned, active, blocked, or complete.
- Observation state: whether optional context collection is active or paused.
- AI state: whether a provider is configured and available.
- Sharing state: whether a specific item is private or shared to a named audience.
Pausing observation does not end the quest. Losing the network does not erase local progress. Joining a community does not turn on observation.
Offer a readily available presentation mode that hides the floating panel. Automatic behavior around screen sharing or full-screen apps should only be described as supported after it has been implemented and verified. The manual control must always be available.
Request optional access only when the user enables the relevant feature. Explain the benefit, what is read, and how to turn it off. A denial leaves the manual goal and game loop usable.
10. Essential states
State	What the user sees	Primary next action
No goal	Complete starting scene and a goal prompt	Create goal
Goal planned	Outcome, criterion, and first quest	Start quest
Quest active	Current action and accepted completion condition	Record progress
Quest blocked	Blocker and optional suggested alternatives	Revise next action
Evidence pending	Specific claim, badge, and remaining condition	Review
Quest complete	Brief reward, saved result, and next quest	Continue or finish
Milestone complete	Durable world change and accomplishment card	View milestone
Goal complete	Named landmark and completion criteria	Keep, archive, or choose a new goal
Observation denied	Manual loop with observation disabled	Continue manually
Observation paused	Clear paused status without ending the quest	Resume observation or continue manually
AI unavailable	Preserved plan and a concise explanation	Edit manually or retry
Community offline	Local personal experience and explicit send status	Keep a draft or retry
Integrity correction	Explainable adjustment in history	Review details
Presentation mode	Overlay hidden, progress preserved	Restore panel


Empty states should look finished. Errors should explain the affected operation and leave unrelated actions available.
11. Keyboard, focus, and accessibility
- The pill can be opened with a configurable shortcut, initially unassigned. Let the user choose a shortcut and detect conflicts; preserve system and VoiceOver key combinations. Clicking the pill and using the menu bar remain available.
- Opening intentionally moves focus to the panel. Background progress never does.
- Escape collapses the panel without cancelling the active quest.
- Clicking outside returns to the prior application. Draft changes should be preserved.
- The ordinary window is available for longer interaction and larger text.
- All controls support keyboard navigation and VoiceOver labels.
- Character animation, color, or spatial position cannot be the only indication of completion.
- Reward announcements should be concise and should not repeatedly interrupt assistive technology.
- Respect reduced motion, increased contrast, and reduced transparency preferences.
- Long goal names, larger fonts, narrow displays, and several displays must not hide the primary action.
12. Copy principles
Use direct language about the work and evidence. Examples:
Use	Avoid
What changed?	Prove you were productive
2 updates to review	AI has verified your productivity
This check passed for the selected revision	Your project is correct
Observation paused	You stopped making progress
Continue when you are ready	Your streak is about to die
Share with Design study group	Share everything
3 of 5 criteria met	An XP-derived outcome percentage


The assistant can be warm and the companion can have personality. Neither should shame the user or treat points as a measure of personal worth.
13. Design review checklist
Before accepting the first implemented experience, verify that:
1. The collapsed object looks intentional on light and dark desktops, with and without a notch.
2. The user can identify the current goal, next action, and observation state without guessing.
3. The expanded panel shows a useful action and a pleasing world in its ordinary initial viewport.
4. Goal metrics and personal XP cannot be mistaken for one another.
5. The user understands why the most recent award and world change happened.
6. Evidence badges communicate their limits in the place where the decision is made.
7. Manual-only use feels complete when every observation permission is denied.
8. The user can return to work immediately after a reward; no animation steals focus.
9. A community message has an obvious audience, and a private AI conversation has an obvious separate destination.
10. Reduced motion, keyboard navigation, VoiceOver, and enlarged text preserve the full core loop.
The product model is defined in PRODUCT_SPEC.md. SCORING.md is authoritative for XP, evidence, and challenge rules. Implementation phases and technical acceptance tests belong in the roadmap and architecture documents.
