# Technical architecture
Status: proposed implementation plan. No application, integration, server, or platform behavior described here is represented as implemented or tested. API references were checked on October 3, 2026. Product behavior remains subject to the acceptance gates below.
1. Decisions and implementation sequence
Build a native macOS application using SwiftUI for presentation and AppKit for its desktop window behavior. Use a pure Swift domain package, explicit SQLite transactions for local persistence, and Keychain for secrets. The complete personal goal loop must work offline without an account, server, API key, or installed local model.
The proposed deployment target is macOS 14.0. At M0, pin an actually available supported Xcode release, Swift language mode, macOS SDK, package versions, and CI runner. Compile availability checks against that SDK. Test the current and previous macOS versions on available real hardware. A deployment target does not certify every intervening OS release; publish the actual tested support matrix and either validate the minimum OS or clearly mark it unverified before release.
Initial hardware QA should cover an Apple Silicon laptop with a notch and an external display. Intel support, Windows, and Linux remain outside the initial release claim until separately tested.
Area	Decision	First required milestone
Desktop shell	SwiftUI hosted by an AppKit NSPanel, plus a normal management window	M1 native spike
Domain	Pure Swift package with injected clock, IDs, and repository interfaces	Personal core
Local storage	SQLite through the system SQLite3 module; one repository actor owns writes	Personal core
Secrets	Keychain items for provider keys and later community sessions	First credential feature
AI	Typed provider interface; deterministic mock and no-AI mode first	AI assessment milestone
Browser	Optional Chrome Manifest V3 extension and native messaging host	M4
Selected capture	Optional ScreenCaptureKit system picker and local Vision OCR	M5
Community	Optional TypeScript, Fastify, PostgreSQL, REST, persistent SSE, Docker Compose	M6


Do not provision the community infrastructure to build the personal app. Do not make a web dashboard the substitute for native desktop acceptance.
Why native
The defining work is focus behavior, a floating panel, display geometry, permission boundaries, and local event handling. AppKit exposes those directly. Tauri can share a web UI across platforms, but its documented process model uses a Rust core and OS webviews, including WKWebView on macOS [A12]. For this macOS-first scope, the extra webview/native boundary would still leave the important native behaviors to implement and verify. This is an architectural judgment, not a measured performance claim about Tauri or Electron.
2. Native presentation layer
2.1 Window ownership and focus
Create an accessory app with a menu bar status item. It owns two presentation surfaces:
1. A compact top-of-screen NSPanel for current quest, progress, brief rewards, and quick actions.
2. A normal management window for onboarding, long goal editing, history, settings, and community conversations.
Create the panel with the nonactivatingPanel style rather than changing that style dynamically between states. SwiftUI content is hosted by AppKit. The collapsed state must never become key or activate the app in response to background events. The expanded state can accept keyboard input after an intentional user action.
Apple defines nonactivatingPanel as a panel that does not activate its owning app [A1]. Apple also specifies the exact focus predicate for becomesKeyOnlyIfNeeded: for a nonactivating panel, the hit view must return true from needsPanelToBecomeKey before the panel becomes key [A2]. SwiftUI hosting does not remove the need to test that predicate through the actual responder chain.
Implement and verify:
- Background progress, XP changes, hover previews, and celebrations do not activate the app, move the text cursor, or consume another app's typing.
- Opening a text field deliberately gives it keyboard input. Escape closes a focused transient panel.
- The previous work app remains usable after dismissal, including when it is in another Space.
- Pointer handling matches the visible panel. No invisible full-screen overlay intercepts clicks or drags.
- Long text workflows use the management window instead of making the small overlay a full application.
- The menu bar always provides Open, Hide overlay, Pause observation, Settings, and Quit.
- A configurable global shortcut may be added through a public shortcut-registration mechanism. It must not require recording all keyboard events. Failure or a shortcut conflict leaves click/menu access working.
- Reduced Motion substitutes short opacity changes for motion-heavy celebrations. Accessibility labels, keyboard order, and sufficient contrast are part of the native UI acceptance.
2.2 Spaces, Stage Manager, and full-screen
Use documented collection behavior only. canJoinAllSpaces describes participation in Spaces. canJoinAllApplications is intended for floating windows and system overlays that can join other apps' full-screen spaces when eligible [A3]. It is mutually exclusive with primary and auxiliary in the Stage Manager behavior group. Do not combine mutually exclusive flags.
Neither flag is a guarantee that the overlay appears over every full-screen application. A current Apple DTS example uses an accessory app, NSPanel, nonactivatingPanel, and the screenSaver window level to demonstrate full-screen behavior on a particular macOS version [A4]. That example establishes feasibility in a tested configuration, not a universal supported product configuration.
The product must not rely on screenSaver-level placement, private window-server APIs, or repeated forced ordering as a shortcut to passing this gate. Test acceptable ordinary window levels and actual application interactions. If acceptable behavior cannot be demonstrated in a full-screen context, hide the overlay there and retain the other access surfaces. Publish that limitation. Do not attempt to appear above lock screens or protected system interfaces.
2.3 Placement and displays
Default to one pill at the top-right below the menu bar on the primary display, with a 16-point horizontal inset; let the user pin a preferred display and choose Top right or Top center. Expanded panels keep the same anchor edge. See ADR-007 in the decision record. Use a stable display identifier when available and recompute its geometry after display changes and wake.
Compute placement in screen points from the intersection of the visible frame and the screen frame adjusted for safeAreaInsets. The intended top inset is a design token, not a presumed notch height. Account for negative monitor origins, scaling, and the distinction between screen points and captured pixels.
NSScreen.safeAreaInsets describes the unobscured content area. auxiliaryTopLeftArea and auxiliaryTopRightArea describe safe areas beside a camera housing when present [A5]. Use those only if a later design explicitly incorporates the notch. The first implementation need not wrap around the physical cutout.
When the selected monitor disappears, fall back to an available primary display. Do not duplicate rewards on multiple displays. Do not infer which monitor contains the current work window from app identity alone.
3. Modules and data ownership
Keep the domain package free of AppKit, browser APIs, network clients, and model SDKs. State transitions accept values and produce values; platform adapters collect evidence but cannot mint rewards.
Proposed source layout
Create these directories when their implementation milestone begins. Their presence is not required in the current specification bundle.
Path	Contents	First milestone
apps/macos	Xcode app target, AppKit shell, SwiftUI views, original world assets	M1
packages/GoalCore	Pure Swift goals, quests, decisions, deterministic personal scoring	M2
packages/GoalStore	SQLite repository, migrations, ledger and retention	M2
packages/GoalAI	Provider adapters, plan and assessment validation	M3
fixtures	Synthetic domain, model, replay, and privacy-boundary cases	M2 onward
extensions/chrome	Manifest V3 extension and native messaging host source	M4
services/community	Optional TypeScript service, PostgreSQL migrations, REST/SSE	M6
deploy	Self-host configuration and release scripts once real	M6–M7


Module	Responsibility	Must not own
App shell	Window lifecycle, navigation, user commands, permission explanations	Scoring policy
Domain	Goals, milestones, quests, assessments, award eligibility, reversals	Screen access, network calls
Local repository	Migrations, transactions, ledger, retention, explicit export	Provider credentials
Observation coordinator	Source consent, epochs, normalization, filtering, bounded queues	Global keystroke/audio recording
Browser adapter	Approved page metadata and explicitly selected evidence	Arbitrary native commands
Capture adapter	User-selected one-off capture and local OCR	Continuous screenshot history
Assessment service	Validated typed requests/responses, provider configuration	Award amounts or executable tools
Reward presenter	Render committed awards, acknowledge presentation	Award creation
Community client	Explicit sharing, membership, chat, canonical score snapshots	Uploading the personal evidence database
Community service	Membership authorization, challenge rules, verified submissions, chat	Trusting local XP as a public score


3.1 Identities and relationships
Use durable opaque IDs, schema versions, and explicit ownership throughout. Wire casing and precise enums belong in the repository's canonical contracts, not ad hoc UI dictionaries.
- A local profile owns goals. A goal owns milestones; a milestone groups quests. Every quest has an explicit goal relationship, completion criteria, and an immutable revision referenced by assessments.
- Evidence records identify their source, collection scope, capture time, privacy epoch, retention policy, and exact associated goal/quest revision where known.
- Assessments reference existing evidence IDs and a goal/quest revision. They record assessment status, explanation, origin, and model/rule version.
- Personal awards reference the accepted decision and the scoring-rule version. A reversal references the original award. Reward presentation is tracked separately from award creation.
- A community has memberships. A season belongs to a community; a challenge has fixed rules and a season relationship. Submissions, verification decisions, and community awards are server-owned.
- A local profile and a community account are separate identities. Joining a community does not automatically publish the local profile's goals, evidence, or lifetime XP.
- Chat messages identify their community, author membership, thread where applicable, creation time, and edit/delete version. A message never doubles as an implicit permission to upload evidence.
Use the same canonical fixtures for cross-language score-policy conformance when the community service is introduced. Do not silently allow Swift and TypeScript implementations to disagree about eligibility, caps, duplicates, or reversals.
4. SQLite persistence and consistency
Choose SQLite instead of SwiftData for the first implementation because award transactions, uniqueness constraints, schema migrations, deletion boundaries, and replay behavior should be explicit and reviewable. Use prepared statements and a small repository layer over the system SQLite3 module.
A serial repository actor owns database access and ensures writes cannot interleave unpredictably. SQLite permits concurrent readers but only one simultaneous writer [A13]; do not scatter independent write connections through UI and adapters.
Enable and check foreign-key enforcement for every connection before opening transactions. SQLite documents that callers must explicitly manage this setting rather than assume it is enabled [A14].
Required invariants:
- A source event has a unique source-scoped idempotency identity.
- An assessment references existing evidence and an eligible current or explicitly retained historical quest revision.
- Accepting a decision, applying its resulting personal award, and marking the decision processed happen in one transaction.
- A uniqueness constraint on the policy-defined award identity prevents duplicate rewards during retries or crash recovery.
- Reversal and correction records preserve audit history while changing derived totals.
- Reward animations begin only after a successful commit. Retrying a presentation cannot create another award.
- Any stored balance is a rebuildable projection. The authoritative personal balance is the ledger interpreted under its recorded rules.
- Migration failure leaves the original store recoverable and opens an actionable recovery flow. Do not reset the user's data silently.
- Disk-full, locked-database, and failed-commit paths show pending/error status instead of success.
Use bounded retry/backoff for a busy store. Use explicit transaction rollback handling. Store large user-retained attachments outside the database with content hashes and managed references; database transactions must not claim a file exists before its durable write succeeds.
Local SQLite files are not encrypted merely because they are local. Keychain protects small credentials, not the entire evidence database [A11]. Any future application-level database encryption requires its own key recovery, migration, and verification design.
5. Observation and evidence collection
5.1 Core mode
Manual quest updates, notes, selected artifacts, timers, and progress review are first-class evidence paths. The core mode works with all optional observation permissions denied.
Normal app observation records only the frontmost app's bundle identifier and bounded activity interval metadata after the user enables it. Do not collect window titles, document paths, accessibility trees, clipboard contents, keystrokes, microphones, cameras, or other apps' databases.
NSWorkspace.frontmostApplication returns the app receiving key events [A6]. That observation does not reveal a document, browser tab, private browsing state, or completed outcome. A nil bundle identifier or unsupported event remains unknown; never invent context.
Coalesce repeated app activations. Exclude the app itself. Use an injected monotonic clock for elapsed intervals and wall time for display/calendar grouping. Do not credit sleep, disconnected intervals, or other unobserved time as work. App duration alone cannot prove goal completion.
5.2 M4 browser adapter
Use a Chrome Manifest V3 extension with two explicitly different access paths:
- Gesture mode: activeTab after the user invokes the extension. Collect the approved title, sanitized origin, or selected page content for the requested evidence action.
- Optional origin mode: request optional_host_permissions only for origins the user deliberately enables. Apply a separate in-app collection allowlist, visible source state, and bounded session rules.
Chrome documents that activeTab is temporary and user-triggered. It permits access to URL/title and, with the relevant API permission, script execution on the granted tab; it does not authorize persistent access across every origin [A7]. Optional host permissions are a separate declared/requested permission mechanism [A8].
Bridge through Chrome native messaging with a narrowly scoped host. Chrome uses a registered host, standard input/output messages, and explicit allowed extension origins [A9]. The helper must not launch arbitrary commands or expose generic filesystem access.
Before accepting any browser event, check all of the following:
1. The paired extension identity and native host protocol version are valid.
2. The sender belongs to the expected extension and the reported tab/frame context is allowed.
3. In gesture mode, the explicit evidence action and its temporary activeTab grant authorize only that selected evidence request. In background origin mode, both the optional browser host grant and the current in-app origin allowlist are required. A gesture does not silently enable persistent observation.
4. The tab is not incognito, the URL is not a restricted/internal scheme, and the event belongs to the current enabled observation session.
5. The message passes strict schema, size, timestamp, and idempotency checks.
6. The app's current privacy epoch still matches before persistence or assessment.
Re-check after asynchronous work. Do not assume a grant remains valid because it existed when a task was scheduled. Drop incognito events even if the user has enabled the extension in incognito. A disconnected helper fails closed and leaves manual evidence available.
By default retain sanitized origins rather than full URLs. Strip credentials, query strings, and fragments. Paths and titles may also contain sensitive data, so include them only under the chosen evidence action and retention setting.
The first protocol caps a normalized browser message at 64 KiB and an extracted text excerpt at 8 KiB. Oversized or malformed input is rejected with an actionable local status. Background collection must not read password fields, form input values, or editable drafts; selected-text evidence is a distinct explicit action with a preview. No new context means no new assessment request.
5.3 M5 selected screen capture
Use SCContentSharingPicker to let the user choose the content, then SCScreenshotManager for a one-off screenshot. Process selected text through Vision locally. Never start a periodic screenshot recorder as an implementation shortcut.
Apple documents passing a picker-generated content filter to the screenshot API [A10]. Its privacy presentation describes selection as session-scoped authorization for the selected content, without requiring a separate blanket screen-recording grant [A15]. Current OS prompts and termination behavior must still be tested; older and newer overloads may have different availability.
Each capture requires a current explicit action, an accepted picker selection, an unchanged privacy epoch, and a still-valid capture session. Picker cancellation, selection loss, provider failure, or unsupported content produces no inferred progress. Local OCR recognizes text; it does not prove that an outcome happened [A16].
Raw screenshots are transient by default. Offer an explicit preview/redaction/retain action before saving or sharing content. Exclude known disallowed apps from picker choices where supported. Do not claim that arbitrary on-screen secrets can be perfectly detected or redacted.
6. Assessment service and AI limits
The personal app ships with a deterministic mock provider for development and a no-AI/manual path for normal use. Cloud BYOK and local model endpoints are opt-in adapters. A local endpoint is not assumed to be installed or available.
No-AI and local-only are distinct settings. No-AI disables model use but does not itself disconnect an explicitly enabled source verifier. The explicit local-only personal profile disables all off-machine requests: cloud AI, remote source checks, community synchronization, telemetry, and update checks. It may use a separately configured loopback model on the same Mac. A LAN or hosted model/service is off-machine and requires the connected profile. Enabling a remote feature explains and records the switch; no silent exception is made inside local-only mode.
Provider credentials live in Keychain. Use separate configuration for provider, model, endpoint, timeout, token budget, and daily request/cost limit. The UI must make the selected processing destination visible. A user-selected local mode must never silently fall back to a cloud provider.
The request contains only approved, minimized context and evidence IDs. Cloud submission requires an enabled cloud destination plus current consent for the exact evidence scope. Never upload API keys, session credentials, raw browser profiles, or an unrestricted screen image.
The typed assessment response contains:
- schema_version and request_id.
- goal_id, quest_id, and quest_version drawn from the request.
- evidence_ids drawn only from the supplied allowed set.
- recommendation, restricted to needs_evidence, needs_confirmation, or irrelevant. An AI response cannot return an accepted completion.
- supported_criteria and missing_criteria referring to the saved criterion set.
- explanation, limited to a short plain-language reason.
- Optional confidence between zero and one, used only as diagnostic model output.
A source verifier has a separate contract with verdict supported, unsupported, or unavailable and the exact predicate/source revision checked. The completion service combines user acceptance or a qualifying source verdict with the saved quest policy. Only that service can create an accepted decision for the deterministic reward engine.
There is no XP field and no arbitrary action/tool field. The model may suggest, but cannot change goals, scoring policy, privacy settings, membership, or published content. Treat confidence as model output rather than a calibrated probability unless calibration is independently demonstrated.
All captured content is untrusted data, including instructions embedded in a page or screenshot. The assessment provider has no shell, browser automation, filesystem, or posting tools. Validate response shape, length, enums, IDs, and goal revision. Reject unknown evidence IDs and stale responses. A malformed response leaves a pending/manual-review state and never awards points.
Bound request frequency and concurrency, coalesce related evidence, and avoid inference when there is no new relevant evidence. Provider timeouts, rate limits, budget exhaustion, and offline conditions do not block the main thread or the manual goal loop.
Initial limits: at most one background assessment in flight, at most 12 background assessments per active hour, and no call without a changed candidate episode. Explicit user-requested planning/review uses a separately visible request and token budget. Display actual request/token use; price estimates require a current provider rate and must not be presented as exact billing. These are proposed limits to validate in the pilot.
6.1 Pause and cancellation epochs
Maintain an integer privacy epoch owned by the observation coordinator. Stamp every observation, capture, queued assessment, and pending evidence upload with the current epoch.
Pause is one serialized transition:
1. Increment the epoch and persist the paused state.
2. Disable collectors and browser/capture session delivery.
3. Clear unsent observation-derived assessment and evidence-upload queues.
4. Cancel in-flight local work and network tasks.
5. Reject later callbacks whose epoch no longer matches.
Before storing evidence, sending a request, accepting an assessment, or creating an award, check that observation is enabled where required and the epoch matches. These checks must occur inside the relevant serialization/transaction boundary, not only when work is enqueued.
Cancellation cannot recall data already delivered to a remote provider. Do not tell the user it does. Pause prevents new collection and new submissions and prevents late responses from producing new observation-driven rewards. Manual entries remain available. Explicit community chat is a separate user action; Pause must not be presented as erasing messages already sent.
Apply the same epoch invalidation to scope revocation, source disabling, account/provider changes, and deletion of the relevant evidence or goal. Resume starts a new session; it must not flush data collected or queued under a previous one.
7. Privacy, retention, and deletion
Expose collection controls per source, excluded origins/apps, current processing destination, Pause, export, and deletion from the normal settings flow.
Recommended defaults are subject to the product privacy contract:
- Raw capture images: memory only unless the user explicitly retains an artifact.
- Coarse observation events and extracted context: short configurable retention, proposed default seven days.
- Accepted goal decisions and personal award ledger: retained with the goal/history until the user deletes them.
- Audit references after evidence expiry: opaque IDs and minimum reason/provenance metadata, not retained raw text.
- Community content: only the user's explicit publication, under the service's disclosed retention policy.
Persist retention deadlines with records. Run bounded expiry cleanup at startup and periodically. Remove attachments and queued requests associated with expired or deleted evidence. An expired artifact cannot be used to reconstruct a supposedly verified new event.
Deletion removes records and app-managed files, invalidates pending work, and applies the specified ledger/history policy atomically where possible. Explain any separate server deletion in the relevant flow. Do not describe ordinary SQLite deletion as forensic erasure; journals, backups, and operating-system snapshots require distinct handling.
Debug logs must omit captured content, credentials, full URLs, and model request bodies by default. Crash reports and analytics remain opt-in and scrubbed. Cloud processing or community storage is not end-to-end encrypted merely because transport uses TLS.
8. Optional M6 community service
Introduce the reference community service only after the personal loop and evidence boundaries pass. Use TypeScript, Fastify, PostgreSQL, REST for commands/queries, and SSE for live updates. Provide Docker Compose for a single application process plus PostgreSQL. This is a proposed self-hostable reference, not a claim that the existing pack contains a running backend.
Keep server and client versions explicit. Choose maintained authentication components during M6 and document the configuration. Do not expose a public multi-user service with demonstration authentication.
8.1 Canonical scores and authorization
Personal XP is local and editable by someone controlling their own open-source client. It must never be trusted as a canonical community score.
For community challenges, the server owns the season, immutable challenge rule revision, eligible membership, submission identity, verification decision, caps, and award ledger. The client submits bounded evidence or an explicit claim. Only the server produces the canonical result.
Every command and query must check authenticated membership for the specific community, including chat, leaderboards, pagination, attachment access, and replay events. Reject expired or revoked memberships. Moderation and membership changes must also invalidate active live subscriptions.
Client-generated operation IDs support retries, not trust. Scope idempotency by authenticated account and operation kind; store a payload hash and reject reuse with different contents. A submission and its resulting community award/outbox event commit transactionally. Never trust client timestamps, claimed XP, or a locally calculated rank.
8.2 Persistent live events and chat
Write a durable community event row in the same PostgreSQL transaction as each accepted mutation. Assign an ordered event ID. SSE delivers only events the current membership can read.
On reconnect, accept a last-event cursor and replay retained authorized events. If the cursor is older than retained history, require a fresh snapshot before resuming. Handle duplicates by event ID. Live delivery is not the source of truth for scores or messages.
Post/edit/delete chat through explicit authenticated REST commands. Live events update views. Keep moderation tombstones/versioning so clients converge after reconnect. An AI draft is not posted until the user chooses to send it.
Initial deployment is one service process with a bounded event dispatcher. Persistent database events support restart recovery. Redis, Kubernetes, a message broker, and horizontally distributed presence are unnecessary until a demonstrated requirement justifies them.
8.3 Public evidence URLs
Do not build an unrestricted server-side URL fetcher. Implement explicit public read-only source adapters. Unsupported links can be displayed as unverified user attachments without being fetched.
For an adapter that fetches a public URL, require:
- A supported HTTPS origin, recognized URL structure, bounded response size, timeout, and accepted content type.
- No embedded credentials, user cookies, authorization headers, or private account access.
- DNS/IP validation that rejects loopback, private, link-local, local-service, and reserved destinations, including IPv6 and mapped-address forms.
- Protection against DNS rebinding at connection time and equivalent checks for every redirect. Prefer refusing redirects unless the adapter explicitly needs an allowed same-source transition.
- Network egress restrictions that independently block internal services and metadata endpoints.
- A parser that checks the exact published challenge predicate. Generic page existence or a model's favorable summary is insufficient.
Never execute downloaded code, clone and run repositories, or execute uploaded artifacts to verify a challenge. Preserve source URL, retrieval time, source-specific identifier, and the validated facts required to audit the decision. A public artifact can support a bounded predicate; it cannot automatically prove who did the underlying work or its business value.
9. Native and boundary acceptance gates
These are proposed pass criteria. Record actual evidence, device/OS/build versions, test method, and any limitation. A screenshot of the UI cannot replace interaction testing.
Gate	Required passing evidence
Native launch	Clean checkout builds with the pinned toolchain and opens a real app bundle; no server, API key, model, or browser extension is needed
Focus	During 100 background progress/reward updates while typing in another app, there are zero activations, cursor moves, lost keystrokes, or consumed shortcuts; deliberate panel text entry and dismissal work
Hit testing	Clicking/dragging immediately outside the visible pill reaches the underlying app; no invisible full-screen capture surface exists
Displays	On one notched laptop and one external display, pinning, scaling, unplug/replug, and wake leave a reachable pill outside menu/notch obstruction
Spaces/full-screen	Current and previous available macOS versions are tested with Stage Manager on/off and at least Safari/Chrome full-screen; supported ordinary-level behavior is documented and unsupported contexts hide the pill
Permissions denied	A fresh user can create a goal, start a quest, enter evidence, receive a personal reward, and review history with every optional observation permission denied
App evidence	Bundle-ID events never include title, URL, document text, clipboard, audio, or keystrokes; an app switch alone cannot complete an outcome quest
Browser grant boundary	Gesture evidence requires its explicit action and temporary activeTab grant; background evidence requires both the browser host grant and in-app allowlist. Incognito, restricted URLs, stale epochs, invalid senders, and oversized/malformed messages are rejected in both paths; reconnect/replay cannot double-award
Capture boundary	Cancel yields no capture; the selected scope is honored; end/revoke prevents later reads; raw capture is not retained without the explicit retain action
Pause race	Pause between collection, queueing, send, response, and commit clears unsent queues and prevents every old-epoch callback from creating an observation-derived award
AI contract	Fabricated IDs, injected instructions, extra tool/XP fields, invalid enums, stale quest revisions, and malformed output are rejected without a reward
Local-only personal profile	The personal workflow completes with zero off-machine requests. Cloud AI, remote verifiers, community sync, telemetry, and update checks are disabled. An explicitly configured same-Mac loopback model is allowed and measured separately; no-AI is tested as an independent option
Ledger	Replaying the canonical 10,000-event fixture gives identical awards/totals; crash/restart at transaction boundaries creates no duplicates or half-applied decisions
Retention	Expiry/deletion removes app-managed context/attachments, cancels dependent unsent work, and follows the documented history policy
Server authorization	At M6, cross-community reads/writes/replays fail; revoked membership loses access; local XP edits cannot change canonical rank
Public URL verifier	At M6, internal addresses, rebinding, redirect escapes, oversized responses, and unsupported origins fail closed; no fetched code executes
Resource budget	Proposed idle target: average app CPU below 1% over ten minutes and resident memory below 150 MB on the named baseline Mac, excluding separately measured optional model processes
UI latency	Proposed target: visible interaction feedback begins within 100 ms, with no main-thread inference/capture work; exact animation timing follows the design specification


If a gate fails, fix the cause or narrow the supported feature claim and document the limitation. Do not weaken a gate silently, fake evidence, or mark unavailable hardware testing as passed.
10. Primary references and what each establishes
References support the stated API boundaries. They do not certify this proposed app's implementation.
- [A1] Apple, nonactivatingPanel. Defines a panel style that does not activate its owning app. https://developer.apple.com/documentation/appkit/nswindow/stylemask-swift.struct/nonactivatingpanel
- [A2] Apple, becomesKeyOnlyIfNeeded. Documents the needsPanelToBecomeKey predicate for keyboard focus in a nonactivating panel. https://developer.apple.com/documentation/appkit/nspanel/becomeskeyonlyifneeded?changes=l_1
- [A3] Apple, canJoinAllApplications. Documents eligible participation in other apps' full-screen spaces and mutual exclusion with primary/auxiliary. https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallapplications
- [A4] Apple Developer Technical Support, overlay across Spaces, May 2026. Provides one tested native configuration, including a screenSaver window level; useful as feasibility evidence, not this product's default. https://developer.apple.com/forums/thread/826308
- [A5] Apple, NSScreen safe-area APIs. Establishes unobscured screen geometry and camera-housing side areas. https://developer.apple.com/documentation/appkit/nsscreen/safeareainsets and https://developer.apple.com/documentation/appkit/nsscreen/auxiliarytopleftarea-uglc
- [A6] Apple, frontmostApplication. Returns the running app receiving key events; this does not document access to its content. https://developer.apple.com/documentation/appkit/nsworkspace/frontmostapplication
- [A7] Chrome, activeTab. Documents explicit invocation, temporary host access, allowed operations, and cross-origin revocation. https://developer.chrome.com/docs/extensions/develop/concepts/activeTab
- [A8] Chrome, permission declarations and requests. Documents optional_host_permissions and runtime permission requests. https://developer.chrome.com/docs/extensions/develop/concepts/declare-permissions and https://developer.chrome.com/docs/extensions/reference/api/permissions
- [A9] Chrome, native messaging. Documents host registration, origin allowlists, protocol framing, and validation boundaries. https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging
- [A10] Apple, What's new in ScreenCaptureKit, WWDC23. Documents the system picker, filter selection, and one-off screenshot API. https://developer.apple.com/videos/play/wwdc2023/10136/
- [A11] Apple, Keychain services. Documents encrypted storage for small secrets; not automatic encryption of arbitrary application files. https://developer.apple.com/documentation/security/keychain-services
- [A12] Tauri, Process Model. Documents Rust core/system-webview architecture and WKWebView on macOS. https://v2.tauri.app/concept/process-model/
- [A13] SQLite, Transactions. Documents explicit transactions, concurrent readers, one writer, busy conditions, and rollback behavior. https://www.sqlite.org/lang_transaction.html
- [A14] SQLite, Foreign Key Support. Documents connection-level foreign-key enabling and enforcement. https://www.sqlite.org/foreignkeys.html
- [A15] Apple, What's new in privacy, WWDC23. Documents user-selected, session-scoped screen capture authorization through SCContentSharingPicker. https://developer.apple.com/videos/play/wwdc2023/10053/
- [A16] Apple, VNRecognizeTextRequest. Documents text recognition in an image. https://developer.apple.com/documentation/vision/vnrecognizetextrequest
