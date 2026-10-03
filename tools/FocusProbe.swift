import AppKit

// Synthetic-only native QA companion. It does not inspect another app or collect
// global keystrokes. The editable field holds only the test operator's input.
@MainActor final class FocusProbeDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(contentRect: CGRect(x: 100,y: 100,width: 620,height: 400),styleMask: [.titled,.closable,.resizable],backing: .buffered,defer: false)
        window.title = "Synthetic Focus Probe"
        let scroll = NSScrollView(frame: window.contentView!.bounds)
        scroll.autoresizingMask = [.width,.height]
        scroll.hasVerticalScroller = true
        let text = NSTextView(frame: scroll.bounds)
        text.isRichText = false
        text.font = .monospacedSystemFont(ofSize: 16,weight: .regular)
        text.textContainerInset = NSSize(width: 16,height: 16)
        text.autoresizingMask = [.width,.height]
        text.setAccessibilityLabel("Synthetic typing fixture")
        text.setAccessibilityIdentifier("focusProbeText")
        scroll.documentView = text
        window.contentView = scroll
        if let screen = NSScreen.screens.first { window.setFrame(screen.visibleFrame,display: true) }
        let main = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit Focus Probe",action: #selector(NSApplication.terminate(_:)),keyEquivalent: "q"))
        appItem.submenu = appMenu
        main.addItem(appItem)
        NSApp.mainMenu = main
        NSApp.activate(ignoringOtherApps: false)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(text)
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
