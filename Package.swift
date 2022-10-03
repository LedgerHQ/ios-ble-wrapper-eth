// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EthWrapper",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "EthWrapper",
            targets: ["EthWrapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LedgerHQ/ios-ble-wrapper", exact: "1.0.0"),
    ],
    targets: [
        .target(
            name: "EthWrapper",
            dependencies: [.product(name: "BleWrapper", package: "ios-ble-wrapper")],
            resources: [.copy("JavaScript/bundle.js")]),
        .testTarget(
            name: "EthWrapperTests",
            dependencies: ["EthWrapper"]),
    ]
)
