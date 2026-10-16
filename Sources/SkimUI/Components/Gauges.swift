import SwiftUI

/// 가로 게이지 + 기준선 (docs/screens.md §7.2 `████▌░░│░░`). Dial `.today-bar`처럼 테두리 없는 오목한 홈.
/// 기준선은 "오늘까지 이만큼 썼으면 딱 맞음" — 채움이 기준선을 넘으면 빠르게 쓰는 중이다.
/// 자리표시(`.redacted(reason: .placeholder)`, `.skeleton`)일 때는 빈 홈만 그리고, 풀리면 차오른다.
public struct LinearGauge: View {
    let progress: Double
    let baseline: Double?
    let fill: Color
    var height: CGFloat
    /// 위젯은 애니메이션 없이 바로 그린다 (타임라인 스냅샷).
    var animated: Bool

    @State private var shown: Double?
    @Environment(\.redactionReasons) private var redactionReasons

    /// 값을 아직 모른다 — 채움·기준선을 그리지 않는다.
    private var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    private var target: Double {
        isPlaceholder ? 0 : progress
    }

    public init(
        progress: Double,
        baseline: Double? = nil,
        fill: Color,
        height: CGFloat = 8,
        animated: Bool = true,
    ) {
        self.progress = progress
        self.baseline = baseline
        self.fill = fill
        self.height = height
        self.animated = animated
    }

    public var body: some View {
        let value = min(max(animated ? (shown ?? 0) : target, 0), 1)
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.fill(0.09))
                Capsule()
                    .fill(fill)
                    .frame(width: value > 0 ? max(width * value, height) : 0)
                if let baseline, !isPlaceholder {
                    // 기준선: 홈을 위아래로 조금 넘는 세로 막대. 바탕색 테두리로 채움과 떨어져 보인다.
                    Capsule()
                        .fill(Palette.ink1)
                        .frame(width: 2.5, height: height + 6)
                        .padding(.horizontal, 1)
                        .background(Capsule().fill(Palette.surface))
                        .offset(x: width * min(max(baseline, 0), 1) - 2.25)
                }
            }
        }
        .frame(height: height)
        .onAppear {
            guard animated else { return }
            withAnimation(.fill) { shown = target }
        }
        .onChange(of: target) { _, value in
            guard animated else { return }
            withAnimation(.fill) { shown = value }
        }
        .accessibilityElement()
        .accessibilityValue(Text("\(Int((progress * 100).rounded()))%"))
    }
}
