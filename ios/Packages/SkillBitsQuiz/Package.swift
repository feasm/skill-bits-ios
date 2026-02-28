// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsQuiz",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsQuiz", targets: ["SkillBitsQuiz"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
    ],
    targets: [
        .target(name: "SkillBitsQuiz", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
        ])
    ]
)
