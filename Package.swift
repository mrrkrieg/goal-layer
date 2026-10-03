// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoalLayer",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "GoalLayer", targets: ["GoalLayer"]), .executable(name: "GoalLayerChecks", targets: ["GoalLayerChecks"])],
    targets: [
        .target(name: "OverlayGeometry", path: "apps/macos/Geometry"),
        .executableTarget(name: "GoalLayer", dependencies: ["OverlayGeometry"], path: "apps/macos/Sources"),
        .executableTarget(name: "GoalLayerChecks", dependencies: ["OverlayGeometry"], path: "Tests/GoalLayerTests")
    ],
    swiftLanguageModes: [.v6]
)
