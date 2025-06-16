// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftdown",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.0"),
        .package(url: "https://github.com/crisfeim/package-mini-swift-server", branch: "main")
    ],
    targets: [
        .target(name: "Core", dependencies: ["Splash"]),
        .executableTarget(
            name: "swiftdown",
            dependencies: [
                "Core",
                .product(name: "MiniSwiftServer", package: "package-mini-swift-server"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "swiftdown", .product(name: "MiniSwiftServer", package: "package-mini-swift-server")],
            resources: [.copy("input")]
        )
    ]
)
