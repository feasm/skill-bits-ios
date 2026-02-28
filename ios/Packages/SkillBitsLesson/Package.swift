// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsLesson",
    platforms: [.iOS(.v17)],
    products: [.library(name: "SkillBitsLesson", targets: ["SkillBitsLesson"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
    ],
    targets: [
        .target(name: "SkillBitsLesson", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
        ])
    ]
)
