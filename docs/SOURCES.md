# Sources and research limits
Checked while preparing the specification on 2026-10-03. The product rules, dimensions, budgets, scoring numbers, milestone order, and pilot thresholds are proposed design decisions, not claims proved by these sources.
Desktop reference
Wispr Flow: Move and Dock the Flow Bar on Desktop
https://docs.wisprflow.ai/articles/1790396454-move-and-dock-the-flow-bar-on-desktop
Verified reference: Wispr describes a small floating status surface, edge docking, screen-aware positioning, and click-through behavior outside controls. Its current documentation describes left, right, and bottom placement; the proposed top placement in Goal Layer is our design choice. Do not copy its brand or assets.
Native Mac APIs
Apple: nonactivatingPanel
https://developer.apple.com/documentation/appkit/nswindow/stylemask-swift.struct/nonactivatingpanel
Reference for a panel that does not activate its owning app. Native focus behavior still needs a prototype and deliberate handling of text entry.
Apple Developer Technical Support: Overlay window above all windows, even when moving spaces
https://developer.apple.com/forums/thread/826308
An Apple DTS answer published in May 2026 reports a tested NSPanel/accessory-app configuration on macOS 26. The example uses a high window level. It establishes feasibility in that test, not universal support or a recommendation that Goal Layer use that level. The plan requires a conservative native spike and a fullscreen fallback.
Apple: NSScreen safeAreaInsets
https://developer.apple.com/documentation/appkit/nsscreen/safeareainsets
The documented safe area reflects obscured screen regions, including the camera housing on some Macs. It supports using runtime geometry instead of hardcoded notch dimensions.
Apple: NSWorkspace frontmostApplication
https://developer.apple.com/documentation/appkit/nsworkspace/frontmostapplication
Returns the frontmost app receiving key events. It does not establish the active page, document content, or whether a goal was completed.
Apple WWDC23: What's new in privacy
https://developer.apple.com/videos/play/wwdc2023/10053/
The screen capture picker section explains user-selected content and capture-session permission. The design uses that boundary for optional selected capture. It does not justify always-on, unrestricted recording.
Apple WWDC23: What's new in ScreenCaptureKit
https://developer.apple.com/videos/play/wwdc2023/10136/
Describes the system picker, content filters, and screenshot API. The actual selected-capture cancellation and revocation path must be tested on supported releases.
Apple: Keychain services
https://developer.apple.com/documentation/security/keychain-services
Reference for storing small credentials using the OS service. Choosing Keychain for keys does not imply that the application's entire SQLite database is encrypted.
Browser context
Chrome: The activeTab permission
https://developer.chrome.com/docs/extensions/develop/concepts/activeTab
Access is granted after a supported user gesture and is temporary. It does not provide continuous all-site background observation.
Chrome: Declare permissions
https://developer.chrome.com/docs/extensions/develop/concepts/declare-permissions
Reference for optional permissions and host access. The proposed background browser mode needs separate origin consent and must remain off until requested.
Chrome: Native messaging
https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging
Describes communication with a registered native host. The application must still validate messages, allowed extension identities, and payload bounds.
Open-source publication
GitHub CLI: gh repo create
https://cli.github.com/manual/gh_repo_create
Documents creating a repository from local source and pushing it. These commands do not establish that a remote repository was actually created during this planning task.
GitHub Choose a License: MIT
https://choosealicense.com/licenses/mit/
Source for the MIT license text and its basic notice-preservation requirement. External dependencies and assets keep their own applicable licenses.
Unproven assumptions to test
- The top overlay is pleasant enough that people leave it enabled.
- A miniature world makes meaningful work feel more rewarding.
- Batched AI suggestions reduce administrative effort.
- Shared challenges add accountability without turning goals into activity farming.
- The chosen performance and interaction budgets are achievable on the declared reference Mac.
- The proposed scope can be maintained by open-source contributors.
The roadmap contains proposed acceptance targets to evaluate these assumptions. No user-study results have been claimed.
