// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsGamification",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsGamification", targets: ["SkillBitsGamification"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
    ],
    targets: [
        .target(name: "SkillBitsGamification", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
        ]),
        .testTarget(name: "SkillBitsGamificationTests", dependencies: ["SkillBitsGamification"])
    ]
)
