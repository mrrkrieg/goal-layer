import CoreGraphics

/// All values are screen points, including negative display origins.
public enum OverlayPlacement {
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

    public static func frame(usable: CGRect, expanded: Bool, horizontalOffset: CGFloat = 0) -> CGRect {
        let gap: CGFloat = min(8, max(0, usable.height / 10))
        let width = min(expanded ? 460 : 300, max(1, usable.width - 16))
        let height = min(expanded ? 560 : 36, max(1, usable.height - gap * 2))
        let centeredX = usable.midX - width / 2 + horizontalOffset
        let x = min(max(centeredX, usable.minX + 8), usable.maxX - width - 8)
        return CGRect(x: x, y: usable.maxY - gap - height, width: width, height: height)
    }
}
