// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ApiVideoPlayerAnalytics",
  platforms: [
    .macOS(.v10_13), .iOS(.v11),
  ],

  products: [
    .library(
      name: "ApiVideoPlayerAnalytics",
      targets: ["ApiVideoPlayerAnalytics"])
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
