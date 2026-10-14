// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "skim-ui-swift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "SkimUI",
            targets: ["SkimUI"],
        ),
    ],
    targets: [
        .target(
            name: "SkimUI",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ],
)
