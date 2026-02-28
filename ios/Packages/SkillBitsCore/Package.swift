// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsCore",
    platforms: [.iOS(.v16)],
    products: [.library(name: "SkillBitsCore", targets: ["SkillBitsCore"])],
    targets: [.target(name: "SkillBitsCore")]
)
