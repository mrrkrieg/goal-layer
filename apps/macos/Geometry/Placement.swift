import CoreGraphics

/// All values are screen points, including negative display origins.
public enum OverlayPlacement {
    public enum Anchor: String, CaseIterable, Sendable {
        case topRight = "top-right"
        case topCenter = "top-center"
    }

    public static func containsVisiblePoint(_ point: CGPoint, frame: CGRect, expanded: Bool) -> Bool {
        // Most global pointer events are outside the small panel. Reject them
        // without allocating a path; include boundaries so CGPath retains the
        // exact edge semantics of the visible rounded region.
        guard point.x >= frame.minX, point.x <= frame.maxX,
              point.y >= frame.minY, point.y <= frame.maxY else { return false }
        let radius: CGFloat = expanded ? 22 : 18
        return CGPath(roundedRect: frame, cornerWidth: radius, cornerHeight: radius, transform: nil).contains(point)
    }
    public static func usableFrame(screen: CGRect, visible: CGRect, safeInsets: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)) -> CGRect {
        let safe = CGRect(x: screen.minX + safeInsets.left, y: screen.minY + safeInsets.bottom,
                          width: max(0, screen.width - safeInsets.left - safeInsets.right),
                          height: max(0, screen.height - safeInsets.top - safeInsets.bottom))
        return safe.intersection(visible)
    }

    public static func frame(usable: CGRect, expanded: Bool, anchor: Anchor = .topRight, horizontalOffset: CGFloat = 0) -> CGRect {
        guard !usable.isNull, !usable.isInfinite, usable.width > 0, usable.height > 0 else { return .null }
        let gap: CGFloat = min(8, max(0, usable.height / 10))
        // Preserve a 16-point side inset where possible. A very narrow usable
        // area reduces the inset rather than pushing the frame off the display.
        let inset = min(16, max(0, (usable.width - 1) / 2))
        let width = min(expanded ? 460 : 300, max(0, usable.width - inset * 2))
        let height = min(expanded ? 560 : 36, max(0, usable.height - gap * 2))
        let minX = usable.minX + inset
        let maxX = usable.maxX - width - inset
        let anchoredX = anchor == .topRight ? maxX : usable.midX - width / 2
        let x = min(max(anchoredX + horizontalOffset, minX), maxX)
        return CGRect(x: x, y: usable.maxY - gap - height, width: width, height: height)
    }
}
