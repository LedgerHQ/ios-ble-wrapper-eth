// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EthereumWrapper",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "EthereumWrapper",
            targets: ["EthereumWrapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LedgerHQ/hw-transport-ios-ble", branch: "main"),
        .package(url: "https://github.com/LedgerHQ/ios-ble-wrapper", branch: "main"),
    ],
    targets: [
        .target(
            name: "EthereumWrapper",
            dependencies: [.product(name: "BleTransport", package: "hw-transport-ios-ble"),
                           .product(name: "BleWrapper", package: "ios-ble-wrapper")],
            resources: [.copy("JavaScript/bundle.js")]),
        .testTarget(
            name: "EthereumWrapperTests",
            dependencies: ["EthereumWrapper"]),
    ]
)
