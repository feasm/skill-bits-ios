// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsSupabase",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SkillBitsSupabase", targets: ["SkillBitsSupabase"])
    ],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "SkillBitsSupabase",
            dependencies: [
                "SkillBitsCore",
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
