import SwiftUI

/// The world is static; only the small expanded companion owns animation ticks.
struct ObservatoryView: View {
    let trait: CharacterTrait
    var animated = false
    var sampleTime: TimeInterval? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ObservatoryBackdrop()
                CompanionView(trait: trait, animated: animated, sampleTime: sampleTime)
                    .frame(width: geometry.size.width * 0.144, height: geometry.size.height * 0.518)
                    .position(x: geometry.size.width * 0.418, y: geometry.size.height * 0.441)
            }
        }
        .frame(height: 136)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Floating observatory with a telescope, lantern, and smiling \(trait.rawValue) explorer companion. Synthetic preview; no achievements yet.")
    }
}

private struct ObservatoryBackdrop: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 400, y: size.height / 136)
            let sky = Path(roundedRect: CGRect(x: 0, y: 0, width: 400, height: 136), cornerRadius: 16)
            context.fill(sky, with: .linearGradient(Gradient(colors: [Color(red: 0.07, green: 0.11, blue: 0.21), Color(red: 0.20, green: 0.18, blue: 0.31)]), startPoint: .zero, endPoint: CGPoint(x: 390, y: 136)))
            var glow = context
            glow.clip(to: sky)
            glow.fill(Path(ellipseIn: CGRect(x: 82, y: 23, width: 246, height: 145)), with: .radialGradient(Gradient(colors: [Palette.mint.opacity(0.10), .clear]), center: CGPoint(x: 206, y: 94), startRadius: 1, endRadius: 115))
            let stars: [(CGFloat, CGFloat, CGFloat)] = [(24,24,1),(66,48,1.4),(96,18,1),(142,30,0.8),(205,14,1.2),(254,27,1),(308,20,1.5),(350,40,1),(373,16,1)]
            for (x,y,r) in stars {
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)), with: .color(.white.opacity(0.70)))
            }
            var constellation = Path()
            constellation.move(to: CGPoint(x: 309,y: 21)); constellation.addLine(to: CGPoint(x: 351,y: 41)); constellation.addLine(to: CGPoint(x: 374,y: 17))
            context.stroke(constellation, with: .color(Palette.mint.opacity(0.23)), lineWidth: 0.8)
            // A suspended island with a softly lit rim and a darker rock underside.
            context.fill(Path(ellipseIn: CGRect(x: 69,y: 108,width: 272,height: 17)), with: .color(.black.opacity(0.18)))
            var base = Path()
            base.move(to: CGPoint(x: 82,y: 88)); base.addLine(to: CGPoint(x: 321,y: 88)); base.addLine(to: CGPoint(x: 294,y: 114)); base.addLine(to: CGPoint(x: 114,y: 114)); base.closeSubpath()
            context.fill(base, with: .linearGradient(Gradient(colors: [Color(red: 0.24,green: 0.34,blue: 0.40), Color(red: 0.14,green: 0.21,blue: 0.30)]), startPoint: CGPoint(x: 170,y: 87), endPoint: CGPoint(x: 170,y: 115)))
            let ground = Path(ellipseIn: CGRect(x: 81,y: 73,width: 241,height: 37))
            context.fill(ground, with: .linearGradient(Gradient(colors: [Color(red: 0.32,green: 0.44,blue: 0.47), Color(red: 0.21,green: 0.32,blue: 0.38)]), startPoint: CGPoint(x: 190,y: 73), endPoint: CGPoint(x: 190,y: 110)))
            context.stroke(ground, with: .color(Palette.mint.opacity(0.33)), lineWidth: 1)
            var walkway = Path(); walkway.move(to: CGPoint(x: 114,y: 94)); walkway.addLine(to: CGPoint(x: 271,y: 94))
            context.stroke(walkway, with: .color(Palette.gold.opacity(0.30)), style: StrokeStyle(lineWidth: 1.5,dash: [2,6]))
            // Telescope: shaded tube, brass mount, and a cool blue lens.
            var tripod = Path(); tripod.move(to: CGPoint(x: 216,y: 59)); tripod.addLine(to: CGPoint(x: 198,y: 94)); tripod.move(to: CGPoint(x: 216,y: 59)); tripod.addLine(to: CGPoint(x: 233,y: 94)); tripod.move(to: CGPoint(x: 216,y: 59)); tripod.addLine(to: CGPoint(x: 216,y: 95))
            context.stroke(tripod, with: .color(Palette.gold), style: StrokeStyle(lineWidth: 2.8,lineCap: .round))
            var tube = Path(); tube.move(to: CGPoint(x: 194,y: 52)); tube.addLine(to: CGPoint(x: 231,y: 31)); tube.addLine(to: CGPoint(x: 241,y: 47)); tube.addLine(to: CGPoint(x: 203,y: 68)); tube.closeSubpath()
            context.fill(tube, with: .linearGradient(Gradient(colors: [Palette.mint, Color(red: 0.29,green: 0.66,blue: 0.66)]), startPoint: CGPoint(x: 215,y: 37), endPoint: CGPoint(x: 221,y: 65)))
            context.stroke(tube, with: .color(.white.opacity(0.45)), lineWidth: 0.8)
            let lens = Path(ellipseIn: CGRect(x: 231,y: 30,width: 11,height: 18))
            context.fill(lens, with: .linearGradient(Gradient(colors: [Color(red: 0.29,green: 0.55,blue: 0.64), Color(red: 0.12,green: 0.29,blue: 0.43)]), startPoint: CGPoint(x: 231,y: 30), endPoint: CGPoint(x: 242,y: 48)))
            context.stroke(lens, with: .color(Palette.mint.opacity(0.7)), lineWidth: 1)
            // Warm window and metallic dome behind the companion.
            context.fill(Path(roundedRect: CGRect(x: 263,y: 60,width: 36,height: 28),cornerRadius: 4), with: .linearGradient(Gradient(colors: [Color(red: 0.31,green: 0.39,blue: 0.54), Color(red: 0.20,green: 0.27,blue: 0.40)]), startPoint: CGPoint(x: 263,y: 61), endPoint: CGPoint(x: 299,y: 88)))
            let dome = Path(ellipseIn: CGRect(x: 258,y: 45,width: 46,height: 27))
            context.fill(dome, with: .linearGradient(Gradient(colors: [Color(red: 0.56,green: 0.65,blue: 0.79), Color(red: 0.32,green: 0.43,blue: 0.62)]), startPoint: CGPoint(x: 270,y: 45), endPoint: CGPoint(x: 290,y: 71)))
            var windowGlow = context
            windowGlow.addFilter(.shadow(color: Palette.gold.opacity(0.45), radius: 5))
            windowGlow.fill(Path(roundedRect: CGRect(x: 275,y: 69,width: 11,height: 14),cornerRadius: 3), with: .color(Color(red: 0.99,green: 0.83,blue: 0.50)))
            var windowFrame = Path(); windowFrame.move(to: CGPoint(x: 280.5,y: 69)); windowFrame.addLine(to: CGPoint(x: 280.5,y: 83))
            context.stroke(windowFrame, with: .color(Color(red: 0.39,green: 0.35,blue: 0.34).opacity(0.3)), lineWidth: 1)
            // A brass lantern casts a small pool of warm light.
            var lamp = context
            lamp.addFilter(.shadow(color: Palette.gold.opacity(0.5), radius: 4))
            lamp.fill(Path(roundedRect: CGRect(x: 119,y: 68,width: 7,height: 12),cornerRadius: 2), with: .color(Palette.gold))
            var lantern = Path(); lantern.move(to: CGPoint(x: 122.5,y: 79)); lantern.addLine(to: CGPoint(x: 122.5,y: 93))
            context.stroke(lantern, with: .color(Palette.gold.opacity(0.75)), lineWidth: 2)
        }
    }
}
