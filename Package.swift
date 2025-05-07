// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftdown",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.0")
    ],
    targets: [
        .target(name: "SwiftDownCore", dependencies: ["Splash"]),
        .executableTarget(
            name: "swiftdown",
            dependencies: [
                "SwiftDownCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "swiftdown-tests",
            dependencies: ["SwiftDownCore"],
            resources: [
                .copy("input")
            ]
        )
    ]
)
