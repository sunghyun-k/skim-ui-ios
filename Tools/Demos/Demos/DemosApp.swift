import SkimUI
import SwiftUI

/// README 데모 영상용 앱. `--demo <이름>`으로 띄운 화면을 `DemosUITests`가 손가락으로 만지고,
/// `Tools/make-demos.sh`가 그동안 녹화해 무대(`stage`)만 잘라 낸다.
@main
struct DemosApp: App {
    private let demo: Demo = {
        let args = ProcessInfo.processInfo.arguments
        return args.firstIndex(of: "--demo")
            .flatMap { args.indices.contains($0 + 1) ? Demo(rawValue: args[$0 + 1]) : nil }
            ?? .toast
    }()

    init() {
        TouchIndicator.install()
    }

    var body: some Scene {
        WindowGroup {
            demo.screen
                .overlay(alignment: .topLeading) { SyncMark() }
                .installToasts()
                .persistentSystemOverlays(.hidden)
        }
    }
}

enum Demo: String, CaseIterable {
    case toast, slider, segmented, expandable, skeleton, selection, tiles

    @MainActor @ViewBuilder var screen: some View {
        switch self {
        case .toast: ToastDemo()
        case .slider: SliderDemo()
        case .segmented: SegmentedDemo()
        case .expandable: ExpandableDemo()
        case .skeleton: SkeletonDemo()
        case .selection: SelectionDemo()
        case .tiles: TilesDemo()
        }
    }
}

/// 녹화 시각 맞추기용. UI 테스트가 누르면 잠깐 자홍색으로 번쩍이고 (홈 화면 아이콘과 헷갈리지 않는 색), `make-demos.sh`가 영상에서 그 순간을 찾는다.
/// 무대 밖(왼쪽 위)이라 잘라 낸 영상에는 담기지 않는다.
struct SyncMark: View {
    static let frame = CGRect(x: 16, y: 70, width: 24, height: 24)
    @State private var isOn = false

    var body: some View {
        // 화면 왼쪽 위 기준 (안전 영역 무시)
        ZStack(alignment: .topLeading) {
            Color.clear
            Rectangle()
                .fill(isOn ? Color(red: 1, green: 0, blue: 1) : Color.black.opacity(0.001))
                .frame(width: Self.frame.width, height: Self.frame.height)
                .padding(.leading, Self.frame.minX)
                .padding(.top, Self.frame.minY)
                .gesture(DragGesture(minimumDistance: 0).onChanged { _ in
                    guard !isOn else { return }
                    isOn = true
                    Task {
                        try? await Task.sleep(for: .seconds(0.3))
                        isOn = false
                    }
                })
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension View {
    /// 영상에 남길 부분. UI 테스트가 이 틀을 읽어 자르기 영역으로 쓴다.
    func stage() -> some View {
        padding(.horizontal, Space.gutter)
            .padding(.vertical, Space.xl)
            // 내용이 아니라 틀 전체를 재도록 뒤에 깐 빈 요소에 이름을 붙인다.
            .background {
                Color.clear
                    .accessibilityElement()
                    .accessibilityLabel("stage")
                    .accessibilityIdentifier("stage")
            }
    }

    /// 무대를 화면 가운데에.
    func centered() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenBackground()
    }
}
