import SwiftUI

/// Original vector illustration; no external assets and no continuous rendering timer.
struct ObservatoryView: View {
    let trait: CharacterTrait
    var body: some View {
        Canvas { context, size in
            let sx = size.width / 400
            let sy = size.height / 136
            context.scaleBy(x: sx, y: sy)
            let sky = CGRect(x: 0, y: 0, width: 400, height: 136)
            context.fill(Path(roundedRect: sky, cornerRadius: 16), with: .linearGradient(
                Gradient(colors: [Color(red: 0.12, green: 0.16, blue: 0.25), Color(red: 0.20, green: 0.19, blue: 0.29)]),
                startPoint: .zero, endPoint: CGPoint(x: 400, y: 136)))
            let stars: [(CGFloat, CGFloat, CGFloat)] = [(24,24,1),(68,44,1.5),(96,18,1),(144,33,1), (205,14,1.5),(249,27,1),(308,20,1.5),(350,40,1),(373,16,1)]
            for (x,y,r) in stars {
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)), with: .color(.white.opacity(0.65)))
            }
            var constellation = Path()
            constellation.move(to: CGPoint(x: 308,y: 20)); constellation.addLine(to: CGPoint(x: 350,y: 40)); constellation.addLine(to: CGPoint(x: 373,y: 16))
            context.stroke(constellation, with: .color(Palette.mint.opacity(0.22)), lineWidth: 1)
            context.fill(Path(ellipseIn: CGRect(x: 84,y: 100,width: 240,height: 24)), with: .color(.black.opacity(0.15)))
            var base = Path()
            base.move(to: CGPoint(x: 96,y: 85)); base.addLine(to: CGPoint(x: 306,y: 85)); base.addLine(to: CGPoint(x: 281,y: 111)); base.addLine(to: CGPoint(x: 121,y: 111)); base.closeSubpath()
            context.fill(base, with: .color(Color(red: 0.26,green: 0.31,blue: 0.36)))
            context.fill(Path(ellipseIn: CGRect(x: 95,y: 67,width: 212,height: 38)), with: .color(Color(red: 0.38,green: 0.43,blue: 0.45)))
            context.stroke(Path(ellipseIn: CGRect(x: 95,y: 67,width: 212,height: 38)), with: .color(Palette.mint.opacity(0.25)), lineWidth: 1)
            var walkway = Path(); walkway.move(to: CGPoint(x: 120,y: 87)); walkway.addLine(to: CGPoint(x: 250,y: 87))
            context.stroke(walkway, with: .color(Palette.gold.opacity(0.35)), style: StrokeStyle(lineWidth: 2,dash: [3,5]))
            // Telescope, tripod, and an illuminated lens.
            var tripod = Path(); tripod.move(to: CGPoint(x: 211,y: 57)); tripod.addLine(to: CGPoint(x: 196,y: 88)); tripod.move(to: CGPoint(x: 211,y: 57)); tripod.addLine(to: CGPoint(x: 224,y: 88)); tripod.move(to: CGPoint(x: 211,y: 57)); tripod.addLine(to: CGPoint(x: 212,y: 89))
            context.stroke(tripod, with: .color(Palette.gold), style: StrokeStyle(lineWidth: 3,lineCap: .round))
            var tube = Path(); tube.move(to: CGPoint(x: 192,y: 53)); tube.addLine(to: CGPoint(x: 223,y: 34)); tube.addLine(to: CGPoint(x: 232,y: 48)); tube.addLine(to: CGPoint(x: 200,y: 65)); tube.closeSubpath()
            context.fill(tube, with: .color(Palette.mint))
            context.stroke(tube, with: .color(.white.opacity(0.5)), lineWidth: 1)
            context.fill(Path(ellipseIn: CGRect(x: 221,y: 33,width: 10,height: 16)), with: .color(Color(red: 0.3,green: 0.48,blue: 0.56)))
            // Small observatory room.
            context.fill(Path(roundedRect: CGRect(x: 248,y: 53,width: 34,height: 30),cornerRadius: 3), with: .color(Color(red: 0.26,green: 0.33,blue: 0.43)))
            context.fill(Path(ellipseIn: CGRect(x: 244,y: 40,width: 42,height: 26)), with: .color(Color(red: 0.44,green: 0.50,blue: 0.60)))
            context.fill(Path(roundedRect: CGRect(x: 258,y: 62,width: 10,height: 13),cornerRadius: 2), with: .color(Palette.gold))
            // Companion and cosmetic trait.
            context.fill(Path(roundedRect: CGRect(x: 158,y: 63,width: 15,height: 20),cornerRadius: 6), with: .color(trait == .builder ? Palette.gold : Palette.mint))
            context.fill(Path(ellipseIn: CGRect(x: 159,y: 51,width: 14,height: 14)), with: .color(Color(red: 0.96,green: 0.84,blue: 0.69)))
            var cap = Path(); cap.move(to: CGPoint(x: 157,y: 55)); cap.addLine(to: CGPoint(x: 166,y: 44)); cap.addLine(to: CGPoint(x: 177,y: 55)); cap.closeSubpath()
            context.fill(cap, with: .color(trait == .connector ? Palette.gold : Color(red: 0.42,green: 0.49,blue: 0.67)))
            var legs = Path(); legs.move(to: CGPoint(x: 161,y: 82)); legs.addLine(to: CGPoint(x: 160,y: 89)); legs.move(to: CGPoint(x: 170,y: 82)); legs.addLine(to: CGPoint(x: 172,y: 89))
            context.stroke(legs, with: .color(.white.opacity(0.7)), style: StrokeStyle(lineWidth: 3,lineCap: .round))
            context.fill(Path(roundedRect: CGRect(x: 126,y: 63,width: 7,height: 11),cornerRadius: 2), with: .color(Palette.gold))
            var lantern = Path(); lantern.move(to: CGPoint(x: 129,y: 72)); lantern.addLine(to: CGPoint(x: 129,y: 85))
            context.stroke(lantern, with: .color(Palette.gold), lineWidth: 2)
        }
        .frame(height: 136)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Floating observatory with a telescope, lantern, and \(trait.rawValue) companion. Synthetic preview; no achievements yet.")
    }
}
