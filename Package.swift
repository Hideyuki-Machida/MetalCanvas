// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetalCanvas",
    platforms: [
        .iOS(.v11), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "MetalCanvas",
            targets: ["MetalCanvasShaders", "MetalCanvas"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Hideyuki-Machida/ProcessLogger.Swift", .branch("master"))
    ],
    targets: [
        .target(
            name: "MetalCanvasShaders",
            dependencies: ["ProcessLogger.Swift"]
        ),
        .target(
            name: "MetalCanvas",
            dependencies: ["MetalCanvasShaders"]
        )
    ]
)
