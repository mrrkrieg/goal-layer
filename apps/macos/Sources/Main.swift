import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var shell: NativeShell?
    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
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
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(15))
                var keyViolations = 0
                var activationViolations = 0
                for index in 1...100 {
                    guard let shell = self?.shell else { return }
                    shell.applyBackgroundPreview(index)
                    if shell.panel.isKeyWindow { keyViolations += 1 }
                    if NSApp.isActive { activationViolations += 1 }
                    try? await Task.sleep(for: .milliseconds(100))
                }
                let report = "PREVIEW_PULSES count=100 key_samples=\(keyViolations) active_samples=\(activationViolations). Typing integrity needs a separate native check.\n"
                FileHandle.standardOutput.write(Data(report.utf8))
                self?.shell?.state.feedback = ""
            }
        }
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
