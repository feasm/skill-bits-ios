// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsNetworking",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsNetworking", targets: ["SkillBitsNetworking"])],
    dependencies: [
        .package(path: "../SkillBitsCore")
    ],
    targets: [
        .target(name: "SkillBitsNetworking", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore")
        ]),
        .testTarget(name: "SkillBitsNetworkingTests", dependencies: ["SkillBitsNetworking"])
    ]
)
