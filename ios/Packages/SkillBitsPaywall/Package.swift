// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsPaywall",
    platforms: [.iOS(.v17)],
    products: [.library(name: "SkillBitsPaywall", targets: ["SkillBitsPaywall"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
    ],
    targets: [
        .target(name: "SkillBitsPaywall", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
        ])
    ]
)
