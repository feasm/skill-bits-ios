// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsCourses",
    platforms: [.iOS(.v17)],
    products: [.library(name: "SkillBitsCourses", targets: ["SkillBitsCourses"])],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(path: "../SkillBitsDesignSystem"),
    ],
    targets: [
        .target(name: "SkillBitsCourses", dependencies: [
            .product(name: "SkillBitsCore", package: "SkillBitsCore"),
            .product(name: "SkillBitsDesignSystem", package: "SkillBitsDesignSystem"),
        ])
    ]
)
