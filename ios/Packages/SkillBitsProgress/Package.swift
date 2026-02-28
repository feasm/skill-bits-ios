// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsProgress",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsProgress", targets: ["SkillBitsProgress"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
        .package(path: "../SkillBitsGamification"),
    ],
    targets: [
        .target(name: "SkillBitsProgress", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
            .product(name: "SkillBitsGamification", package: "SkillBitsGamification"),
        ])
    ]
)
