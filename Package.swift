// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ApiVideoPlayerAnalytics",
    platforms: [
        .iOS(.v11),
        .tvOS(.v12),
        .visionOS(.v1),
        .macOS(.v10_13),
        .macCatalyst(.v14)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ApiVideoPlayerAnalytics",
            targets: ["ApiVideoPlayerAnalytics"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        .target(
            name: "ApiVideoPlayerAnalytics",
            path: "Sources"
        ),
        // Targets for tests
        .testTarget(
            name: "ApiVideoPlayerAnalyticsTests",
            dependencies: ["ApiVideoPlayerAnalytics"],
            path: "Tests"
        )
    ]
)
