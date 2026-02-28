// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsProfile",
    platforms: [.iOS(.v17)],
    products: [.library(name: "SkillBitsProfile", targets: ["SkillBitsProfile"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
        .package(path: "../SkillBitsGamification"),
    ],
    targets: [
        .target(name: "SkillBitsProfile", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
            .product(name: "SkillBitsGamification", package: "SkillBitsGamification"),
        ])
    ]
)
