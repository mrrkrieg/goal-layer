import SwiftUI

/// Original vector companion. Only the expanded sprite owns a live schedule.
struct CompanionView: View {
    let trait: CharacterTrait
    var animated = false
    var portrait = false
    /// Deterministic artwork fixtures; never used as runtime model state.
    var sampleTime: TimeInterval? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startedAt = Date()

    var body: some View {
        Group {
            if animated && !reduceMotion && !portrait && sampleTime == nil {
                TimelineView(.animation(minimumInterval: 1.0 / 24)) { timeline in
                    artwork(time: timeline.date.timeIntervalSince(startedAt))
                }
            } else {
                artwork(time: sampleTime ?? 0)
            }
        }
        .accessibilityHidden(true)
    }

    private func artwork(time: TimeInterval) -> some View {
        Canvas { context, size in
            let scale = min(size.width / (portrait ? 64 : 72), size.height / (portrait ? 48 : 88))
            context.translateBy(x: (size.width - (portrait ? 64 : 72) * scale) / 2,
                                y: (size.height - (portrait ? 48 : 88) * scale) / 2)
            context.scaleBy(x: scale, y: scale)
            if portrait {
                context.translateBy(x: -4, y: -2)
                CompanionArt.helmet(in: context, blink: 1)
            } else {
                CompanionArt.draw(in: context, trait: trait, time: max(0, time))
            }
        }
    }
}

private enum CompanionArt {
    static let ink = Color(red: 0.10, green: 0.15, blue: 0.25)
    static let pearl = Color(red: 0.87, green: 0.92, blue: 0.99)

    static func draw(in context: GraphicsContext, trait: CharacterTrait, time: TimeInterval) {
        let accent: Color = switch trait {
        case .builder: Palette.gold
        case .explorer: Palette.mint
        case .connector: Color(red: 0.76, green: 0.69, blue: 1)
        }
        let bob = sin(time * 2.2) * 1.1
        let wavePhase = time.truncatingRemainder(dividingBy: 9)
        let wave = wavePhase > 2.5 && wavePhase < 4.2 ? sin((wavePhase - 2.5) / 1.7 * .pi) : 0
        let blinkPhase = time.truncatingRemainder(dividingBy: 5.4)
        let blink = blinkPhase > 4.7 && blinkPhase < 4.9 ? abs((blinkPhase - 4.8) / 0.1) : 1
        let sway = sin(time * 2) * 1.5
        context.fill(Path(ellipseIn: CGRect(x: 17, y: 81, width: 42, height: 6)), with: .color(.black.opacity(0.22)))
        var body = context
        body.translateBy(x: 0, y: bob)
        // Backpack and small articulated legs sit behind the suit.
        rounded(CGRect(x: 18, y: 48, width: 15, height: 24), radius: 6, color: ink, in: body)
        rounded(CGRect(x: 19, y: 50, width: 9, height: 18), radius: 4, color: accent.opacity(0.7), in: body)
        rounded(CGRect(x: 26, y: 69, width: 9, height: 12), radius: 4, color: pearl, in: body)
        rounded(CGRect(x: 39, y: 69, width: 9, height: 12), radius: 4, color: pearl, in: body)
        rounded(CGRect(x: 22, y: 77, width: 14, height: 7), radius: 3, color: ink, in: body)
        rounded(CGRect(x: 39, y: 77, width: 15, height: 7), radius: 3, color: ink, in: body)
        line(from: CGPoint(x: 25, y: 80), to: CGPoint(x: 32, y: 80), color: accent, width: 2, in: body)
        line(from: CGPoint(x: 42, y: 80), to: CGPoint(x: 49, y: 80), color: accent, width: 2, in: body)
        let suit = Path(roundedRect: CGRect(x: 24, y: 46, width: 28, height: 29), cornerRadius: 10)
        body.fill(suit, with: .linearGradient(Gradient(colors: [pearl, Color(red: 0.55, green: 0.65, blue: 0.82)]), startPoint: CGPoint(x: 28, y: 47), endPoint: CGPoint(x: 48, y: 74)))
        body.stroke(suit, with: .color(ink), lineWidth: 1.5)
        // A quiet left arm and an occasional friendly right-hand wave.
        line(from: CGPoint(x: 26, y: 52), to: CGPoint(x: 21, y: 65), color: pearl, width: 7, in: body)
        body.fill(Path(ellipseIn: CGRect(x: 17, y: 63, width: 8, height: 9)), with: .color(accent))
        let hand = CGPoint(x: 59 + sin(time * 9) * wave * 1.4, y: 61 - wave * 24)
        line(from: CGPoint(x: 50, y: 52), to: hand, color: ink, width: 8.5, in: body)
        line(from: CGPoint(x: 50, y: 52), to: hand, color: pearl, width: 6, in: body)
        body.fill(Path(ellipseIn: CGRect(x: hand.x - 4.5, y: hand.y - 4.5, width: 9, height: 9)), with: .color(accent))
        rounded(CGRect(x: 29, y: 54, width: 18, height: 13), radius: 4, color: ink.opacity(0.85), in: body)
        body.fill(star(center: CGPoint(x: 38, y: 60), radius: 4), with: .color(accent))
        line(from: CGPoint(x: 29, y: 70), to: CGPoint(x: 46, y: 70), color: .white.opacity(0.45), width: 1, in: body)
        // The scarf is the selected role's cosmetic color.
        var tail = Path()
        tail.move(to: CGPoint(x: 46, y: 44)); tail.addLine(to: CGPoint(x: 63, y: 47 + sway))
        tail.addLine(to: CGPoint(x: 59, y: 55 + sway)); tail.addLine(to: CGPoint(x: 44, y: 50)); tail.closeSubpath()
        body.fill(tail, with: .color(accent.opacity(0.85)))
        helmet(in: body, blink: max(0.06, blink))
        rounded(CGRect(x: 25, y: 43, width: 27, height: 7), radius: 3.5, color: accent, in: body)
        line(from: CGPoint(x: 29, y: 45), to: CGPoint(x: 45, y: 45), color: .white.opacity(0.4), width: 1, in: body)
    }

    static func helmet(in context: GraphicsContext, blink: Double) {
        let shell = Path(roundedRect: CGRect(x: 14, y: 8, width: 45, height: 39), cornerRadius: 18)
        var shadow = context
        shadow.addFilter(.shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2))
        shadow.fill(shell, with: .linearGradient(Gradient(colors: [pearl, Color(red: 0.49, green: 0.59, blue: 0.77)]), startPoint: CGPoint(x: 23, y: 9), endPoint: CGPoint(x: 56, y: 43)))
        context.stroke(shell, with: .color(ink), lineWidth: 1.5)
        rounded(CGRect(x: 11, y: 23, width: 7, height: 13), radius: 3, color: Color(red: 0.43, green: 0.54, blue: 0.73), in: context)
        rounded(CGRect(x: 55, y: 23, width: 7, height: 13), radius: 3, color: Color(red: 0.43, green: 0.54, blue: 0.73), in: context)
        let visor = Path(roundedRect: CGRect(x: 19, y: 15, width: 35, height: 27), cornerRadius: 12)
        context.fill(visor, with: .linearGradient(Gradient(colors: [Color(red: 0.06, green: 0.12, blue: 0.23), Color(red: 0.14, green: 0.27, blue: 0.37)]), startPoint: CGPoint(x: 23, y: 16), endPoint: CGPoint(x: 48, y: 42)))
        context.stroke(visor, with: .color(Color(red: 0.43, green: 0.59, blue: 0.74)), lineWidth: 1)
        var reflection = Path()
        reflection.move(to: CGPoint(x: 24, y: 22)); reflection.addQuadCurve(to: CGPoint(x: 43, y: 18), control: CGPoint(x: 29, y: 17))
        context.stroke(reflection, with: .color(.white.opacity(0.22)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        for x: CGFloat in [28, 43] {
            rounded(CGRect(x: x - 2, y: 28 - 3.4 * blink, width: 4, height: 6.8 * blink), radius: 2, color: Palette.mint, in: context)
        }
        for x: CGFloat in [25, 47] {
            context.fill(Path(ellipseIn: CGRect(x: x - 2, y: 32, width: 4, height: 2)), with: .color(Color(red: 0.97, green: 0.66, blue: 0.67).opacity(0.6)))
        }
        var smile = Path()
        smile.move(to: CGPoint(x: 33, y: 34)); smile.addQuadCurve(to: CGPoint(x: 39, y: 34), control: CGPoint(x: 36, y: 37))
        context.stroke(smile, with: .color(Palette.mint.opacity(0.9)), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
        rounded(CGRect(x: 31, y: 9, width: 12, height: 3), radius: 1.5, color: .white.opacity(0.65), in: context)
    }

    private static func rounded(_ rect: CGRect, radius: CGFloat, color: Color, in context: GraphicsContext) {
        context.fill(Path(roundedRect: rect, cornerRadius: radius), with: .color(color))
    }
    private static func line(from: CGPoint, to: CGPoint, color: Color, width: CGFloat, in context: GraphicsContext) {
        var path = Path(); path.move(to: from); path.addLine(to: to)
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
    private static func star(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for index in 0..<8 {
            let angle: Double = Double(index) * Double.pi / 4 - Double.pi / 2
            let r = index.isMultiple(of: 2) ? radius : radius * 0.38
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * r, y: center.y + CGFloat(sin(angle)) * r)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath(); return path
    }
}
