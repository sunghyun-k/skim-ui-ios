import SwiftUI

/// 세그먼트 탭: 오목한 트랙(`fill3`) 위로 선택 알약이 미끄러진다. 높이는 글자에서 나온다 (다이내믹 타입).
/// 누르거나 끌어서 고른다 (0.x `SegmentedSelectStyle` 방식): 끄는 동안 알약이 손가락을 따라가며 살짝 작아지고,
/// 손을 떼면 그 칸이 선택된다. 칸은 모두 같은 폭이라 위치로 칸을 바로 계산한다.
public struct SegmentedControl<Value: Hashable>: View {
    @Binding var selection: Value
    let options: [(value: Value, label: String)]

    @State private var dragIndex: Int?
    /// 놓아서 고른 칸. 바인딩이 부모를 거쳐 늦게 돌아오면 그 사이 알약이 옛 칸으로 튀었다 돌아와 햅틱이 겹친다 —
    /// 선택이 실제로 바뀔 때까지 붙잡아 둔다.
    @State private var pendingIndex: Int?

    /// 놓았을 때·고를 때 곡선.
    private static var settle: Animation {
        .spring(duration: 0.3, bounce: 0.15)
    }

    public init(selection: Binding<Value>, options: [(value: Value, label: String)]) {
        _selection = selection
        self.options = options
    }

    private var selectedIndex: Int? {
        options.firstIndex { $0.value == selection }
    }

    /// 알약 위치: 끄는 중이면 손가락 아래 칸, 놓은 뒤 선택이 돌아오기 전이면 놓은 칸.
    private var indicatorIndex: Int? {
        dragIndex ?? pendingIndex ?? selectedIndex
    }

    public var body: some View {
        let track = RoundedRectangle(cornerRadius: Radius.track, style: .continuous)
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.value) { index, option in
                let isActive = index == indicatorIndex
                Text(option.label)
                    .textRole(.callout)
                    .foregroundStyle(isActive ? Palette.ink1 : Palette.ink3)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .animation(Self.settle, value: isActive)
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(index == selectedIndex ? [.isButton, .isSelected] :
                        .isButton)
                    .accessibilityAction { select(index) }
            }
        }
        .background(alignment: .leading) { indicator }
        .contentShape(.rect)
        // 세로로 쓸면 스크롤이 가져간다 (SwiftUI `DragGesture`는 스크롤 뷰 안에서 위아래 스크롤을 막는다).
        .gesture(
            HorizontalDragGesture(
                onChanged: { dragIndex = index(at: $0.x) },
                onEnded: { location in
                    let target = index(at: location.x)
                    withAnimation(Self.settle) {
                        dragIndex = nil
                        if let target, target != selectedIndex {
                            pendingIndex = target
                            select(target)
                        }
                    }
                },
                onCancelled: { withAnimation(Self.settle) { dragIndex = nil } },
            ),
        )
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .padding(3.5)
        .background(track.fill(Palette.fill3))
        .sensoryFeedback(.selection, trigger: indicatorIndex)
        .onChange(of: selection) { pendingIndex = nil }
    }

    @State private var width: CGFloat = 0

    @ViewBuilder private var indicator: some View {
        if let index = indicatorIndex, !options.isEmpty, width > 0 {
            let segment = width / CGFloat(options.count)
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .fill(Palette.tabPill)
                .shadow(color: Palette.popShadow.opacity(0.6), radius: 1, y: 1)
                .frame(width: segment)
                .scaleEffect(dragIndex != nil ? 0.95 : 1)
                .offset(x: segment * CGFloat(index))
                .animation(dragIndex != nil ? .interactiveSpring() : Self.settle, value: index)
                .animation(.spring(duration: 0.2), value: dragIndex != nil)
        }
    }

    private func index(at x: CGFloat) -> Int? {
        guard !options.isEmpty, width > 0 else { return nil }
        return min(max(Int(x / (width / CGFloat(options.count))), 0), options.count - 1)
    }

    private func select(_ index: Int) {
        let value = options[index].value
        if value != selection {
            selection = value
        }
    }
}

/// 단계 슬라이더 (Dial 모래시계 팝오버의 `.slider-track`).
/// 홈(`fill3`) 위 단계마다 점, 테마색 채움이 손잡이까지 차오른다 — 채움 끝은 오른쪽만 살짝 둥글다.
/// 손잡이는 왼쪽 반원 바로 뒤에서, 오른쪽은 반원의 가운데에서 멈춘다 — 최소일 때도 채움의 왼쪽 반원이 남는다.
/// 흰 세로 손잡이는 잡으면 세로로 늘고 홈은 눌린다. 정해진 값에서만 멈추고 멈출 때마다 햅틱.
/// 양옆 원형 −/+, 끝에 닿으면 흐려진다. 아래 양 끝에 최소·최대.
public struct SteppedSlider<Value: Hashable>: View {
    @Binding var selection: Value
    let steps: [Value]
    let label: (Value) -> String

    @State private var dragIndex: Int?

    public init(selection: Binding<Value>, steps: [Value], label: @escaping (Value) -> String) {
        _selection = selection
        self.steps = steps
        self.label = label
    }

    private let trackHeight: CGFloat = 32
    private let dot: CGFloat = 7

    private var index: Int {
        dragIndex ?? steps.firstIndex(of: selection) ?? 0
    }

    private var fraction: CGFloat {
        steps.count > 1 ? CGFloat(index) / CGFloat(steps.count - 1) : 1
    }

    public var body: some View {
        VStack(spacing: Space.xs) {
            HStack(spacing: Space.s) {
                stepButton(increment: false)
                track
                stepButton(increment: true)
            }
            if let first = steps.first, let last = steps.last {
                HStack {
                    Text(label(first))
                    Spacer()
                    Text(label(last))
                }
                .textRole(.caption)
                .foregroundStyle(Palette.ink4)
                .padding(.horizontal, trackHeight + Space.s)
            }
        }
        .sensoryFeedback(.selection, trigger: index)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(Text(label(selection)))
        .accessibilityAdjustableAction { direction in
            move(by: direction == .increment ? 1 : -1)
        }
    }

    /// 손잡이 가운데가 갈 수 있는 범위. 왼쪽은 반원 바로 뒤(채움이 반원보다 좁아지면 캡슐이 찌그러진다),
    /// 오른쪽은 반원의 가운데까지 (채움 끝이 곡선을 파고들면 각져 보인다).
    private func knobRange(width: CGFloat) -> ClosedRange<CGFloat> {
        let leading = trackHeight / 2 + knobWidth / 2
        let trailing = max(width - trackHeight / 2, leading)
        return leading ... trailing
    }

    private func knobX(_ fraction: CGFloat, width: CGFloat) -> CGFloat {
        let range = knobRange(width: width)
        return range.lowerBound + (range.upperBound - range.lowerBound) * fraction
    }

    private let knobWidth: CGFloat = 9

    private func drag(to x: CGFloat, width: CGFloat) {
        let range = knobRange(width: width)
        let span = max(range.upperBound - range.lowerBound, 1)
        let raw = (x - range.lowerBound) / span * CGFloat(steps.count - 1)
        let step = min(max(Int(raw.rounded()), 0), steps.count - 1)
        // 단계가 바뀔 때만 상태를 건드린다 (손가락이 움직일 때마다 다시 그리지 않게).
        guard step != dragIndex else { return }
        dragIndex = step
        selection = steps[step]
    }

    private var track: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let x = knobX(fraction, width: width)
            // 채움은 손잡이 오른쪽 끝까지.
            let edge = x + knobWidth / 2
            let isDragging = dragIndex != nil
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.fill3)
                // 단계가 많으면(데이터 제공량 23단계) 점이 빽빽해서 그리지 않는다.
                ForEach(
                    steps.count <= 15 ? Array(1 ..< max(steps.count - 1, 1)) : [],
                    id: \.self,
                ) { step in
                    Circle()
                        .fill(Palette.fill(0.2))
                        .frame(width: dot, height: dot)
                        .offset(x: knobX(CGFloat(step) / CGFloat(steps.count - 1), width: width) -
                            dot / 2)
                }
                UnevenRoundedRectangle(
                    topLeadingRadius: trackHeight / 2,
                    bottomLeadingRadius: trackHeight / 2,
                    bottomTrailingRadius: 6,
                    topTrailingRadius: 6,
                    style: .continuous,
                )
                .fill(Palette.theme)
                .frame(width: edge)
                Capsule()
                    .fill(Palette.knob)
                    .overlay { Capsule().strokeBorder(Palette.popShadow, lineWidth: 0.5) }
                    .shadow(color: Palette.popShadow, radius: 1.5, y: 1)
                    .frame(width: knobWidth, height: 24)
                    .scaleEffect(x: 1, y: isDragging ? 1.12 : 1)
                    .offset(x: x - knobWidth / 2)
            }
            .clipShape(Capsule())
            .insetRing(Capsule(), 0.06)
            .scaleEffect(x: 1, y: isDragging ? 0.94 : 1)
            .animation(.roll, value: index)
            .animation(.timingCurve(0.23, 1, 0.32, 1, duration: 0.16), value: isDragging)
            .contentShape(.rect)
            // 세로로 쓸면 스크롤이 가져간다 (SwiftUI `DragGesture`는 스크롤 뷰 안에서 위아래 스크롤을 막는다). 누르면 그 자리로.
            .gesture(
                HorizontalDragGesture(
                    onChanged: { drag(to: $0.x, width: width) },
                    onEnded: { location in
                        drag(to: location.x, width: width)
                        dragIndex = nil
                    },
                    onCancelled: { dragIndex = nil },
                ),
            )
        }
        .frame(height: trackHeight)
    }

    private func stepButton(increment: Bool) -> some View {
        let enabled = increment ? index < steps.count - 1 : index > 0
        return Button {
            move(by: increment ? 1 : -1)
        } label: {
            IconView(increment ? .plus : .minus, size: 15)
                .foregroundStyle(Palette.ink2)
                .frame(width: trackHeight, height: trackHeight)
                .background(Circle().fill(Palette.fill3))
        }
        .buttonStyle(.pressable)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.3)
        .accessibilityHidden(true)
    }

    private func move(by delta: Int) {
        let next = min(max(index + delta, 0), steps.count - 1)
        selection = steps[next]
    }
}
