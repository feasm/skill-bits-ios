// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsAuth",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsAuth", targets: ["SkillBitsAuth"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
    ],
    targets: [
        .target(name: "SkillBitsAuth", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
        ])
    ]
)
