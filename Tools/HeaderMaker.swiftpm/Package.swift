// swift-tools-version: 6.0
// README 헤더 이미지 생성기 (App Playground). `Tools/make-header.sh`로 돌리거나 Xcode에서 실행한다.
// 저장소 폴더 이름이 패키지 이름(skim-ui-swift)이 된다.
import AppleProductTypes
import PackageDescription

let package = Package(
    name: "HeaderMaker",
    platforms: [.iOS("18.0")],
    products: [
        .iOSApplication(
            name: "HeaderMaker",
            targets: ["HeaderMaker"],
            bundleIdentifier: "local.skimui.headermaker",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .sparkle),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [.phone],
            supportedInterfaceOrientations: [.portrait],
        ),
    ],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "HeaderMaker",
            dependencies: [.product(name: "SkimUI", package: "skim-ui-swift")],
            path: "Sources",
        ),
    ],
)
