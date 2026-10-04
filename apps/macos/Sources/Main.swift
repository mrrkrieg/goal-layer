import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var shell: NativeShell?
    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
        // Export only our original art offscreen, without creating the desktop shell.
        if let path = Self.argument("--art-preview", in: arguments) {
            do { try Self.saveArtwork(to: path, time: Double(Self.argument("--art-time", in: arguments) ?? "0") ?? 0) }
            catch { print("Artwork save failed: \(error)") }
            NSApp.terminate(nil)
            return
        }
        let state = SpikeState(isDemo: arguments.contains("--demo"))
        shell = NativeShell(state: state)
        if arguments.contains("--expanded") { shell?.expand() }
        if arguments.contains("--dark-preview") { shell?.panel.appearance = NSAppearance(named: .darkAqua) }
        if let index = arguments.firstIndex(of: "--snapshot"), arguments.indices.contains(index + 1) {
            let path = arguments[index + 1]
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(2))
                do { try self?.shell?.savePreview(to: path) } catch { print("Preview save failed: \(error)") }
            }
        }
        if let index = arguments.firstIndex(of: "--diagnostics"), arguments.indices.contains(index + 1) {
            let path = arguments[index + 1]
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(3))
                guard let state = self?.shell?.diagnosticState() else { return }
                do { try JSONSerialization.data(withJSONObject: state,options: [.prettyPrinted,.sortedKeys]).write(to: URL(fileURLWithPath: path),options: .atomic) }
                catch { print("Diagnostics save failed: \(error)") }
            }
        }
        if arguments.contains("--preview-pulses") {
            let reportPath = Self.argument("--qa-report", in: arguments)
            Task { @MainActor [weak self] in
                if let startPath = Self.argument("--qa-start-file", in: arguments) {
                    // Opt-in synthetic QA coordination; no desktop content is read.
                    for _ in 0..<600 {
                        if FileManager.default.fileExists(atPath: startPath) { break }
                        try? await Task.sleep(for: .milliseconds(100))
                    }
                    guard FileManager.default.fileExists(atPath: startPath) else { return }
                    try? await Task.sleep(for: .seconds(1))
                } else { try? await Task.sleep(for: .seconds(15)) }
                let started = Date().timeIntervalSince1970
                var samples: [[String: Any]] = []
                for index in 1...100 {
                    guard let shell = self?.shell else { return }
                    shell.applyBackgroundPreview(index)
                    let frontmost = NSWorkspace.shared.frontmostApplication
                    samples.append([
                        "index": index, "timestamp": Date().timeIntervalSince1970,
                        "panel_key": shell.panel.isKeyWindow, "app_active": NSApp.isActive,
                        // This opt-in QA checks one known synthetic app identity. It
                        // never records another application's name, title, or content.
                        "frontmost_is_focus_probe": frontmost?.bundleIdentifier == "org.goallayer.focus-probe",
                        "frontmost_available": frontmost != nil,
                        "frontmost_has_bundle_identifier": frontmost?.bundleIdentifier != nil
                    ])
                    try? await Task.sleep(for: .milliseconds(250))
                }
                let keyViolations = samples.filter { $0["panel_key"] as? Bool == true }.count
                let activationViolations = samples.filter { $0["app_active"] as? Bool == true }.count
                let report: [String: Any] = ["schema": "native-focus-pulses-v1", "started_at": started,
                    "ended_at": Date().timeIntervalSince1970, "samples": samples,
                    "count": samples.count, "key_violations": keyViolations, "activation_violations": activationViolations]
                if let reportPath {
                    do { try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
                        .write(to: URL(fileURLWithPath: reportPath), options: .atomic) }
                    catch { print("QA report save failed: \(error)") }
                }
                let line = "PREVIEW_PULSES count=100 key_samples=\(keyViolations) active_samples=\(activationViolations). See timestamped probe report for typing integrity.\n"
                FileHandle.standardOutput.write(Data(line.utf8))
                self?.shell?.state.feedback = ""
            }
        }
    }
    private static func saveArtwork(to path: String, time: TimeInterval) throws {
        let bounds = NSRect(x: 0, y: 0, width: 400, height: 136)
        let view = NSHostingView(rootView: ObservatoryView(trait: .explorer, sampleTime: time))
        // A retained but unordered window supplies native rendering context only.
        let window = NSWindow(contentRect: bounds, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = view
        view.frame = bounds
        view.layoutSubtreeIfNeeded()
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: bounds) else {
            throw CocoaError(.fileWriteUnknown)
        }
        view.cacheDisplay(in: bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try png.write(to: URL(fileURLWithPath: path), options: .atomic)
        withExtendedLifetime(window) {}
    }

    private static func argument(_ name: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

@main
enum GoalLayerMain {
    @MainActor static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = AppDelegate()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }
}
