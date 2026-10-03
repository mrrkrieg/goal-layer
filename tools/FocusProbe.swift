import AppKit

// Synthetic-only native QA companion. It does not read another app’s content or record
// global keystrokes. The editable field holds only the test operator's input.
@MainActor final class FocusProbeDelegate: NSObject, NSApplicationDelegate, NSTextViewDelegate, NSWindowDelegate {
    var window: NSWindow!
    private var reportPath: String?
    private var startMarkerPath: String?
    private var samples: [[String: Any]] = []
    private var lastSampleTime = 0.0
    private var lastTextSampleTime = 0.0
    private var previousSelectionLength = 0
    private var textEventCount = 0
    private var mismatchEventCount = 0
    private var unexpectedTextCaretEventCount = 0
    private var unexpectedTextFocusEventCount = 0
    private let fixtureUnit = "abcdefghij0123456789"
    private var textView: NSTextView!
    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
        if let index = arguments.firstIndex(of: "--record"), arguments.indices.contains(index + 1) { reportPath = arguments[index + 1] }
        if let index = arguments.firstIndex(of: "--start-marker"), arguments.indices.contains(index + 1) { startMarkerPath = arguments[index + 1] }
        window = NSWindow(contentRect: CGRect(x: 100,y: 100,width: 620,height: 400),styleMask: [.titled,.closable,.resizable],backing: .buffered,defer: false)
        window.title = "Goal Layer · Temporary typing test"
        window.delegate = self
        let scroll = NSScrollView(frame: window.contentView!.bounds)
        scroll.autoresizingMask = [.width,.height]
        scroll.hasVerticalScroller = true
        let text = NSTextView(frame: scroll.bounds)
        textView = text
        text.delegate = self
        text.isRichText = false
        text.isAutomaticQuoteSubstitutionEnabled = false
        text.isAutomaticDashSubstitutionEnabled = false
        text.isAutomaticSpellingCorrectionEnabled = false
        text.font = .monospacedSystemFont(ofSize: 16,weight: .regular)
        text.textContainerInset = NSSize(width: 16,height: 16)
        text.autoresizingMask = [.width,.height]
        text.setAccessibilityLabel("Synthetic typing fixture")
        text.setAccessibilityIdentifier("focusProbeText")
        scroll.documentView = text
        let content = NSView()
        let explanation = NSTextField(wrappingLabelWithString: "Temporary Goal Layer QA window. This field checks whether overlay updates interrupt typing. Use synthetic test text only. Close this window or press Command-Q to finish; this is not the Goal Layer app.")
        explanation.font = .systemFont(ofSize: 13)
        explanation.translatesAutoresizingMaskIntoConstraints = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(explanation)
        content.addSubview(scroll)
        var aboveField = explanation.bottomAnchor
        if startMarkerPath != nil {
            let startButton = NSButton(title: "Start 100-update typing test", target: self, action: #selector(startTest))
            startButton.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(startButton)
            NSLayoutConstraint.activate([
                startButton.topAnchor.constraint(equalTo: explanation.bottomAnchor, constant: 12),
                startButton.leadingAnchor.constraint(equalTo: explanation.leadingAnchor)
            ])
            aboveField = startButton.bottomAnchor
        }
        NSLayoutConstraint.activate([
            explanation.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            explanation.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            explanation.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            scroll.topAnchor.constraint(equalTo: aboveField, constant: 12),
            scroll.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])
        window.contentView = content
        if arguments.contains("--maximized"), let screen = NSScreen.screens.first {
            window.setFrame(screen.visibleFrame, display: true)
        } else { window.center() }
        let main = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit Focus Probe",action: #selector(NSApplication.terminate(_:)),keyEquivalent: "q"))
        appItem.submenu = appMenu
        main.addItem(appItem)
        let editItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editItem.submenu = editMenu
        main.addItem(editItem)
        NSApp.mainMenu = main
        NSApp.activate(ignoringOtherApps: false)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(text)
        record("ready")
    }
    @objc private func startTest() {
        guard let startMarkerPath else { return }
        // Only the explicit QA button creates the synthetic coordination marker.
        NSApp.activate(ignoringOtherApps: false)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)
        do {
            try Data("synthetic-focus-test".utf8).write(to: URL(fileURLWithPath: startMarkerPath), options: .atomic)
            record("start_marker")
        } catch { print("Could not start typing test: \(error)") }
    }
    func textDidChange(_ notification: Notification) { record("text") }
    func textViewDidChangeSelection(_ notification: Notification) { record("selection") }
    func applicationWillTerminate(_ notification: Notification) { record("termination"); saveReport() }
    func windowDidBecomeKey(_ notification: Notification) { record("became_key") }
    func windowDidResignKey(_ notification: Notification) { record("resigned_key") }
    func windowDidEnterFullScreen(_ notification: Notification) { record("entered_fullscreen") }
    func windowDidExitFullScreen(_ notification: Notification) { record("exited_fullscreen") }

    private func record(_ event: String) {
        guard reportPath != nil, let textView else { return }
        let value = textView.string
        let expected = String(String(repeating: fixtureUnit, count: value.count / fixtureUnit.count + 1).prefix(value.count))
        let selection = textView.selectedRange()
        let now = Date().timeIntervalSince1970
        let restoredSelection = previousSelectionLength > 0 && selection.length == 0
        previousSelectionLength = selection.length
        let mismatch = value != expected
        let unexpectedCaret = event == "text" && (selection.location != value.count || selection.length != 0)
        let unexpectedFocus = event == "text" && (!window.isKeyWindow || !NSApp.isActive)
        if event == "text" { textEventCount += 1 }
        if mismatch { mismatchEventCount += 1 }
        if unexpectedCaret { unexpectedTextCaretEventCount += 1 }
        if unexpectedFocus { unexpectedTextFocusEventCount += 1 }
        // Check every callback; retain at most one ordinary sample per 50 ms.
        // Deliberate selection, lifecycle, and all failures are always retained.
        let ordinarySampleDue = event == "text" ? now - lastTextSampleTime >= 0.05 : now - lastSampleTime >= 0.05
        guard ordinarySampleDue || !["text", "selection"].contains(event) || selection.length > 0 || restoredSelection || mismatch || unexpectedCaret || unexpectedFocus else { return }
        lastSampleTime = now
        if event == "text" { lastTextSampleTime = now }
        samples.append(["timestamp": now, "event": event,
            "character_count": value.count, "fixture_prefix_matches": value == expected,
            "selection_location": selection.location, "selection_length": selection.length,
            "window_key": window.isKeyWindow, "app_active": NSApp.isActive,
            "fullscreen": window.styleMask.contains(.fullScreen),
            "frontmost_is_self": NSWorkspace.shared.frontmostApplication?.processIdentifier == NSRunningApplication.current.processIdentifier,
            "frontmost_available": NSWorkspace.shared.frontmostApplication != nil])
    }

    private func saveReport() {
        guard let reportPath, let textView else { return }
        let value = textView.string
        let expected = String(String(repeating: fixtureUnit, count: value.count / fixtureUnit.count + 1).prefix(value.count))
        let selection = textView.selectedRange()
        let report: [String: Any] = ["schema": "synthetic-focus-probe-v2", "fixture_unit": fixtureUnit,
            "sample_method": "every callback checked; ordinary samples at most once per 50 ms; selection and failures retained",
            "own_bundle_identifier": Bundle.main.bundleIdentifier ?? "unregistered",
            "own_running_bundle_matches": NSRunningApplication.current.bundleIdentifier == "org.goallayer.focus-probe",
            "text_event_count": textEventCount, "fixture_mismatch_event_count": mismatchEventCount,
            "unexpected_text_caret_event_count": unexpectedTextCaretEventCount,
            "unexpected_text_focus_event_count": unexpectedTextFocusEventCount,
            "samples": samples, "final_character_count": value.count,
            "final_fixture_matches": value == expected,
            "final_selection_location": selection.location, "final_selection_length": selection.length]
        do { try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            .write(to: URL(fileURLWithPath: reportPath), options: .atomic) }
        catch { print("Probe report save failed: \(error)") }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

@main enum FocusProbeMain {
    @MainActor static func main() {
        let app = NSApplication.shared
        let delegate = FocusProbeDelegate()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }
}
