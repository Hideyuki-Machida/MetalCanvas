// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetalCanvas",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "MetalCanvas",
            targets: ["MetalCanvasShaders", "MetalCanvas"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MetalCanvasShaders"
        ),
        .target(
            name: "MetalCanvas",
            dependencies: ["MetalCanvasShaders"]
        )
    ]
)
