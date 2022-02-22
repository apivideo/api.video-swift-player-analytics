// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApiVideoPlayerAnalytics",
    products: [
        .library(
            name: "ApiVideoPlayerAnalytics",
            targets: ["ApiVideoPlayerAnalytics"]),
    ],
    targets: [
        .target(
            name: "ApiVideoPlayerAnalytics",
            dependencies: [],
            path: "Sources"),
            
        .testTarget(
            name: "ApiVideoPlayerAnalyticsTests",
            dependencies: ["ApiVideoPlayerAnalytics"],
            path: "Tests"
        ),
    ]
)
