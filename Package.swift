// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftdown",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .target(name: "SwiftDownCore"),
        .target(name: "swiftdown"),
        .executableTarget(
            name: "swiftdown-cli",
            dependencies: [
                "swiftdown",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "swiftdown-tests",
            dependencies: ["swiftdown"],
            resources: [
                .copy("input")
            ]
        )
    ]
)
