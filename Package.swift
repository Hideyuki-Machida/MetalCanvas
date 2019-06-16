// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MetalCanvas",
    products: [
        .library(name: "MetalCanvas", targets: ["MetalCanvas"])
    ],
    targets: [
        .target(name: "MetalCanvas", dependencies: [])
    ],
    swiftLanguageVersions: [.v5]
)
