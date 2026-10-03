import SwiftUI
import Observation

@MainActor @Observable
final class SpikeState {
    var expanded = false
    var overlayHidden = false
    var presentationMode = false
    var draft = ""
    var trait = CharacterTrait.explorer
    var quiet = false
    var largerText = false
    var feedback = ""
    var pulse = 0
    let isDemo: Bool
    var openPanel: () -> Void = {}
    var collapse: () -> Void = {}
    var openWindow: () -> Void = {}

    init(isDemo: Bool) { self.isDemo = isDemo }
    var nextAction: String { isDemo ? "Resolve the implementation question" : "Choose your first goal" }
}

enum CharacterTrait: String, CaseIterable, Identifiable {
    case builder = "Builder", explorer = "Explorer", connector = "Connector"
    var id: String { rawValue }
}

enum Palette {
    static let night = Color(red: 0.090, green: 0.106, blue: 0.149)
    static let mint = Color(red: 0.659, green: 0.941, blue: 0.867)
    static let gold = Color(red: 0.851, green: 0.745, blue: 0.490)
}
