import AppKit
import SwiftUI
import OverlayGeometry
import ColorSync

@MainActor
final class OverlayPanel: NSPanel {
    var expanded = false
    var dismiss: () -> Void = {}
    override var canBecomeKey: Bool { expanded }
    override var canBecomeMain: Bool { false }
    override func cancelOperation(_ sender: Any?) { dismiss() }
}

@MainActor
final class PanelHostingView: NSHostingView<OverlayRoot> {
    override var needsPanelToBecomeKey: Bool { (window as? OverlayPanel)?.expanded == true }
}

@MainActor
final class NativeShell: NSObject, NSWindowDelegate {
    let state: SpikeState
    let panel: OverlayPanel
    private var statusItem: NSStatusItem!
    private var managementWindow: NSWindow?
    private var localClickMonitor: Any?
    private var globalClickMonitor: Any?
    private var localPointerMonitor: Any?
    private var globalPointerMonitor: Any?
    private var notificationTokens: [NSObjectProtocol] = []
    private var workspaceTokens: [NSObjectProtocol] = []
    private var selectedDisplayUUID: String?
    private let settings = UserDefaults.standard

    init(state: SpikeState) {
        self.state = state
        panel = OverlayPanel(contentRect: CGRect(x: 0,y: 0,width: 300,height: 36),
                             styleMask: [.borderless,.nonactivatingPanel], backing: .buffered, defer: false)
        super.init()
        selectedDisplayUUID = settings.string(forKey: "selectedDisplayUUID")
        panel.title = "Goal Layer"
        panel.identifier = NSUserInterfaceItemIdentifier("GoalLayerOverlay")
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        // Intentionally omit fullScreenAuxiliary / canJoinAllApplications for the first spike.
        // Ordinary full-screen Spaces retain menu access; universal overlay support is unclaimed.
        panel.collectionBehavior = [.canJoinAllSpaces,.transient,.ignoresCycle]
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.isReleasedWhenClosed = false
        panel.isMovable = false
        panel.acceptsMouseMovedEvents = true
        panel.delegate = self
        panel.contentView = PanelHostingView(rootView: OverlayRoot(state: state))
        panel.dismiss = { [weak self] in self?.collapse() }
        state.openPanel = { [weak self] in self?.expand() }
        state.collapse = { [weak self] in self?.collapse() }
        state.openWindow = { [weak self] in self?.showManagementWindow() }
        setupMainMenu()
        setupMenu()
        observeGeometry()
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown,.rightMouseDown]) { [weak self] event in
            if let self, event.window !== self.panel { self.collapse() }
            return event
        }
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown,.rightMouseDown]) { [weak self] _ in
            // Mouse events are used only for dismissing the transient panel; nothing is retained.
            MainActor.assumeIsolated { self?.collapse() }
        }
        localPointerMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved,.leftMouseDragged,.rightMouseDragged]) { [weak self] event in
            self?.updatePointerRegion()
            return event
        }
        globalPointerMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved,.leftMouseDragged,.rightMouseDragged]) { [weak self] _ in
            MainActor.assumeIsolated { self?.updatePointerRegion() }
        }
        reconcileVisibility()
    }

    func expand() {
        state.overlayHidden = false
        state.presentationMode = false
        state.expanded = true
        panel.expanded = true
        if place() { panel.makeKeyAndOrderFront(nil) } else { panel.orderOut(nil) }
        updateMenu()
    }

    func collapse() {
        guard state.expanded else { return }
        // Ordering out relinquishes panel key status to the previous work window.
        panel.orderOut(nil)
        state.expanded = false
        panel.expanded = false
        reconcileVisibility()
    }

    func showManagementWindow() {
        collapse()
        if managementWindow == nil {
            let window = NSWindow(contentRect: CGRect(x: 0,y: 0,width: 640,height: 680),styleMask: [.titled,.closable,.miniaturizable,.resizable],backing: .buffered,defer: false)
            window.title = "Goal Layer · Plan and Settings"
            window.contentView = NSHostingView(rootView: PlanningWindowView(state: state))
            window.minSize = NSSize(width: 460,height: 500)
            window.isReleasedWhenClosed = false
            window.center()
            managementWindow = window
        }
        NSApp.activate(ignoringOtherApps: false)
        managementWindow?.makeKeyAndOrderFront(nil)
    }

    @discardableResult func place() -> Bool {
        let screens = NSScreen.screens
        let screen = screens.first(where: { displayUUID($0) == selectedDisplayUUID && selectedDisplayUUID != nil }) ?? screens.first
        guard let screen else { return false }
        let insets = screen.safeAreaInsets
        let usable = OverlayPlacement.usableFrame(screen: screen.frame,visible: screen.visibleFrame,
                                                 safeInsets: (insets.top,insets.left,insets.bottom,insets.right))
        guard !usable.isNull, usable.width >= 32, usable.height >= 32 else { return false }
        panel.setFrame(OverlayPlacement.frame(usable: usable,expanded: state.expanded),display: true)
        updatePointerRegion()
        return true
    }

    private func reconcileVisibility() {
        guard !state.overlayHidden, !state.presentationMode, place() else { panel.orderOut(nil); return }
        panel.orderFrontRegardless()
    }

    private func updatePointerRegion() {
        // Pointer position is used transiently for native hit testing only, never recorded.
        // The whole rectangular window passes through when the pointer is in a clipped corner.
        panel.ignoresMouseEvents = !OverlayPlacement.containsVisiblePoint(NSEvent.mouseLocation,frame: panel.frame,expanded: state.expanded)
    }

    func applyBackgroundPreview(_ index: Int) {
        // No activation/window-order calls are allowed in this path. No ledger exists in M1.
        state.pulse = index
        state.feedback = state.quiet ? "" : "Preview update \(index) · no XP"
    }

    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "sparkles",accessibilityDescription: "Goal Layer")
        statusItem.button?.toolTip = "Goal Layer — open, hide, or restore your observatory"
        updateMenu()
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem()
        let applicationMenu = NSMenu()
        let quitItem = item("Quit Goal Layer", #selector(quit))
        quitItem.keyEquivalent = "q"
        applicationMenu.addItem(quitItem)
        applicationItem.submenu = applicationMenu
        mainMenu.addItem(applicationItem)
        let editItem = NSMenuItem(title: "Edit",action: nil,keyEquivalent: "")
        let editMenu = NSMenu(title: "Edit")
        for (title,selector,key) in [("Undo",Selector(("undo:")),"z"),("Cut",#selector(NSText.cut(_:)),"x"),("Copy",#selector(NSText.copy(_:)),"c"),("Paste",#selector(NSText.paste(_:)),"v"),("Select All",#selector(NSText.selectAll(_:)),"a")] {
            editMenu.addItem(NSMenuItem(title: title,action: selector,keyEquivalent: key))
        }
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)
        NSApp.mainMenu = mainMenu
    }

    func savePreview(to path: String) throws {
        guard let view = panel.contentView, let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds,to: bitmap)
        guard let data = bitmap.representation(using: .png,properties: [:]) else { return }
        try data.write(to: URL(fileURLWithPath: path),options: .atomic)
    }

    func diagnosticState() -> [String: Any] {
        ["schema": "native-spike-diagnostics-v1", "expanded": state.expanded,
         "app_active": NSApp.isActive, "panel_key": panel.isKeyWindow,
         "window_level": panel.level.rawValue, "display_count": NSScreen.screens.count,
         "frame": ["x": panel.frame.minX,"y": panel.frame.minY,"width": panel.frame.width,"height": panel.frame.height],
         "displays": NSScreen.screens.map { screen in
             ["frame": ["x":screen.frame.minX,"y":screen.frame.minY,"width":screen.frame.width,"height":screen.frame.height],
              "safe_top": screen.safeAreaInsets.top, "scale": screen.backingScaleFactor]
         }, "observation_enabled": false, "network_features": false]
    }

    private func item(_ title: String,_ action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title,action: action,keyEquivalent: "")
        item.target = self
        return item
    }

    private func updateMenu() {
        let menu = NSMenu()
        menu.addItem(item("Open Goal Layer",#selector(openFromMenu)))
        menu.addItem(item("Plan and Settings…",#selector(settingsFromMenu)))
        menu.addItem(item(state.overlayHidden ? "Restore overlay" : "Hide overlay",#selector(toggleOverlay)))
        let presentation = item("Presentation mode",#selector(togglePresentation))
        presentation.state = state.presentationMode ? .on : .off
        menu.addItem(presentation)
        let displayMenu = NSMenu()
        for screen in NSScreen.screens {
            let displayItem = item(screen.localizedName,#selector(selectDisplay(_:)))
            displayItem.representedObject = displayUUID(screen)
            displayItem.state = displayUUID(screen) == selectedDisplayUUID && selectedDisplayUUID != nil ? .on : .off
            displayMenu.addItem(displayItem)
        }
        let displayItem = NSMenuItem(title: "Display",action: nil,keyEquivalent: "")
        displayItem.submenu = displayMenu
        menu.addItem(displayItem)
        menu.addItem(.separator())
        let observation = NSMenuItem(title: "Observation off — not implemented",action: nil,keyEquivalent: "")
        menu.addItem(observation)
        let quitItem = item("Quit Goal Layer",#selector(quit))
        quitItem.keyEquivalent = "q"
        menu.addItem(quitItem)
        statusItem.menu = menu
        NSApp.mainMenu?.items.first?.submenu = menu.copy() as? NSMenu
    }

    private func displayID(_ screen: NSScreen) -> UInt32? {
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }

    private func displayUUID(_ screen: NSScreen) -> String? {
        guard let id = displayID(screen), let uuid = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil,uuid) as String
    }

    private func observeGeometry() {
        notificationTokens.append(NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,object: nil,queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.reconcileVisibility(); self?.updateMenu() }
        })
        let workspace = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.activeSpaceDidChangeNotification] {
            workspaceTokens.append(workspace.addObserver(forName: name,object: nil,queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.collapse(); self?.reconcileVisibility() }
            })
        }
    }

    @objc private func openFromMenu() { expand() }
    @objc private func settingsFromMenu() { showManagementWindow() }
    @objc private func toggleOverlay() {
        collapse()
        state.overlayHidden.toggle()
        reconcileVisibility()
        updateMenu()
    }
    @objc private func togglePresentation() {
        collapse()
        state.presentationMode.toggle()
        reconcileVisibility()
        updateMenu()
    }
    @objc private func selectDisplay(_ sender: NSMenuItem) {
        guard let uuid = sender.representedObject as? String else { return }
        selectedDisplayUUID = uuid
        settings.set(uuid,forKey: "selectedDisplayUUID")
        reconcileVisibility()
        updateMenu()
    }
    @objc private func quit() { NSApp.terminate(nil) }
}
