// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "skim-ui-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v26),
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
