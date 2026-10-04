import CoreGraphics
import OverlayGeometry
import Foundation

// A deterministic assertion runner works with the pinned Command Line Tools, which
// do not contain XCTest. Assertions use explicit failure exits in release builds.
var failures = 0
var checks = 0
@MainActor func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    checks += 1
    if !condition() { failures += 1; print("FAIL: \(message)") }
}

let screen = CGRect(x: 0,y: 0,width: 1512,height: 982)
let visible = CGRect(x: 0,y: 40,width: 1512,height: 904)
let usable = OverlayPlacement.usableFrame(screen: screen,visible: visible,safeInsets: (38,0,0,0))
let pill = OverlayPlacement.frame(usable: usable,expanded: false)
check(pill.maxY == 936,"Menu/notch exclusions intersect; they must not be added twice")
check(pill.size == CGSize(width: 300,height: 36),"Collapsed size is 300×36 points")
check(usable.contains(pill),"Notched display contains collapsed panel")
check(pill.maxX == usable.maxX-16,"Default position is 16 points from the usable right edge")
let expandedPanel = OverlayPlacement.frame(usable: usable,expanded: true)
check(expandedPanel.maxX == pill.maxX,"Expansion keeps the collapsed panel's right edge")
check(expandedPanel.maxY == pill.maxY,"Expansion keeps the same menu/notch gap")
let centeredPill = OverlayPlacement.frame(usable: usable,expanded: false,anchor: .topCenter)
check(centeredPill.midX == usable.midX,"Top center remains available as a centered anchor")

let rightDockVisible = CGRect(x: 0,y: 40,width: 1432,height: 904)
let rightDockUsable = OverlayPlacement.usableFrame(screen: screen,visible: rightDockVisible,safeInsets: (38,0,0,0))
let rightDockPill = OverlayPlacement.frame(usable: rightDockUsable,expanded: false)
check(rightDockPill.maxX == rightDockVisible.maxX-16,"Top right respects a Dock exclusion on the right edge")
check(rightDockUsable.contains(rightDockPill),"Dock and notch exclusions contain the top-right panel")

let negative = CGRect(x: -1920,y: -300,width: 1920,height: 1080)
let negativeVisible = CGRect(x: -1920,y: -270,width: 1920,height: 1026)
let negativeUsable = OverlayPlacement.usableFrame(screen: negative,visible: negativeVisible,safeInsets: (0,0,0,0))
for expanded in [false,true] {
    let frame = OverlayPlacement.frame(usable: negativeUsable,expanded: expanded,horizontalOffset: -5000)
    check(negativeUsable.contains(frame),"Negative-origin display contains \(expanded ? "expanded" : "collapsed") panel")
    check(frame.minX == negativeUsable.minX+16,"Left offset clamps within new display")
    let anchoredFrame = OverlayPlacement.frame(usable: negativeUsable,expanded: expanded)
    check(anchoredFrame.maxX == negativeUsable.maxX-16,"Top-right \(expanded ? "expanded" : "collapsed") anchor follows a negative-origin display")
}

let small = CGRect(x: 0,y: 0,width: 320,height: 400)
let smallExpanded = OverlayPlacement.frame(usable: small,expanded: true)
check(smallExpanded.width == 288,"Narrow screen constrains width while keeping 16-point side insets")
check(smallExpanded.height == 384,"Short screen constrains height")
check(small.contains(smallExpanded),"Small display contains expanded panel")
check(smallExpanded.maxX == small.maxX-16,"Constrained expansion stays aligned to the right inset")

let minimum = CGRect(x: -40,y: -50,width: 32,height: 32)
for anchor in OverlayPlacement.Anchor.allCases {
    let frame = OverlayPlacement.frame(usable: minimum,expanded: true,anchor: anchor)
    check(minimum.contains(frame) && frame.width > 0 && frame.height > 0,"Minimum usable area contains a nonempty \(anchor.rawValue) frame")
}

let shifted = CGRect(x: 20,y: 30,width: 800,height: 600)
let offsetPill = OverlayPlacement.frame(usable: shifted,expanded: false,horizontalOffset: 3000)
check(offsetPill.maxX == shifted.maxX-16,"Right offset clamps on changed display")
check(shifted.contains(offsetPill),"Clamped panel remains on display")
let disjoint = OverlayPlacement.usableFrame(screen: screen,visible: CGRect(x: 2000,y: 2000,width: 100,height: 100),safeInsets: (0,0,0,0))
check(disjoint.isNull,"Disconnected/invalid geometry cannot produce a usable area")
check(OverlayPlacement.frame(usable: disjoint,expanded: false).isNull,"An invalid area cannot produce a top-right frame")
let hitFrame = CGRect(x: 20,y: 30,width: 300,height: 36)
check(OverlayPlacement.containsVisiblePoint(CGPoint(x: 170,y: 48),frame: hitFrame,expanded: false),"Pill center is interactive")
check(!OverlayPlacement.containsVisiblePoint(CGPoint(x: 21,y: 31),frame: hitFrame,expanded: false),"Invisible rounded corner is outside the interaction shape")
check(!OverlayPlacement.containsVisiblePoint(CGPoint(x: 10,y: 40),frame: hitFrame,expanded: false),"Point outside panel is outside interaction shape")
print("Placement checks: \(checks-failures)/\(checks) passed. Geometry checks do not certify native display behavior.")
exit(failures == 0 ? 0 : 1)
