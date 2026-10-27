import SwiftUI

/// 고를 수 있는 칩. 한 줄이면 캡슐(필터·별칭), 두 줄이면 모서리 둥근 판(데이터 프리셋 "11GB + 일 2GB / 소진 시 3Mbps"),
/// 짧은 값 여러 개(할인 기간 "6개월")는 `.square`.
/// 고르면 옅은 테마색 판 + 테마색 테두리 (`selectionPlate`).
public struct SelectChip: View {
    public enum Shape: Sendable {
        case capsule
        case square
    }

    let title: String
    let detail: String?
    let isSelected: Bool
    let shape: Shape
    let action: () -> Void

    public init(
        _ title: String,
        detail: String? = nil,
        isSelected: Bool,
        shape: Shape = .capsule,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.detail = detail
        self.isSelected = isSelected
        self.shape = detail == nil ? shape : .square
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textRole(detail == nil && shape == .capsule ? .footnote : .callout)
                    .foregroundStyle(isSelected ? Palette.ink1 : Palette.ink2)
                if let detail {
                    Text(detail)
                        .textRole(.caption)
                        .foregroundStyle(Palette.ink4)
                }
            }
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, shape == .capsule ? 13 : 12)
            .padding(.vertical, detail == nil ? 0 : 8)
            .frame(minWidth: shape == .square ? 56 : nil, minHeight: shape == .capsule ? 34 : 40)
            .background { background }
            .contentShape(.rect)
        }
        .buttonStyle(.pressable)
        .animation(.soft, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var background: some View {
        switch shape {
        case .capsule: plate(Capsule())
        case .square: plate(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        }
    }

    private func plate(_ shape: some InsettableShape) -> some View {
        shape.selectionPlate(isSelected: isSelected)
    }
}

/// 가로로 미는 칩 줄. `systemMargins()` 로 띄운 화면 안에 두면 화면 가장자리까지 넘치게 그리고, 칩은 시스템 여백에서 시작한다.
public struct ChipScroller<Content: View>: View {
    let content: Content
    @State private var margins = EdgeInsets(
        top: 0,
        leading: SystemMargin.fallback,
        bottom: 0,
        trailing: SystemMargin.fallback,
    )

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) { content }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.leading, margins.leading, for: .scrollContent)
        .contentMargins(.trailing, margins.trailing, for: .scrollContent)
        .padding(.leading, -margins.leading)
        .padding(.trailing, -margins.trailing)
        .onGeometryChange(for: EdgeInsets.self) { $0.systemMargins } action: { margins = $0 }
    }
}

/// 둥근 점 라디오. 고르면 테마색으로 꽉 차고 가운데 검정 점 — 얇은 선이 아니라 면이라 라이트에서도 또렷하다.
public struct RadioDot: View {
    let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public var body: some View {
        ZStack {
            Circle().strokeBorder(Palette.fill(0.25), lineWidth: 1.5)
                .opacity(isSelected ? 0 : 1)
            Circle()
                .fill(Palette.theme)
                .scaleEffect(isSelected ? 1 : 0.4)
                .opacity(isSelected ? 1 : 0)
            Circle()
                .fill(Palette.onTheme)
                .padding(6)
                .scaleEffect(isSelected ? 1 : 0.2)
                .opacity(isSelected ? 1 : 0)
        }
        .frame(width: 18, height: 18)
        .animation(.strongOut, value: isSelected)
        .accessibilityHidden(true)
    }
}

/// 카드형 라디오 ("기간 한정 할인" / "평생 할인 · 할인 없음"). 누르면 바로 다음으로 넘어가는 질문에 쓴다.
public struct ChoiceCard: View {
    let title: String
    let message: String?
    let isSelected: Bool
    let action: () -> Void

    public init(
        _ title: String,
        message: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.message = message
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: Space.m) {
                RadioDot(isSelected: isSelected)
                    .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .textRole(.headline)
                        .foregroundStyle(Palette.ink1)
                    if let message {
                        Text(message)
                            .textRole(.footnote)
                            .foregroundStyle(Palette.ink3)
                    }
                }
                Spacer(minLength: 0)
            }
            .multilineTextAlignment(.leading)
            .padding(Space.l)
            .background {
                shape.selectionPlate(isSelected: isSelected)
            }
            .contentShape(shape)
        }
        .buttonStyle(.pressableCard)
        .animation(.soft, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 시트 안 고르기 행 ("SIM 1 / 오늘 1.9GB 사용 · 셀룰러 데이터", "연동 안 함"). 고른 행은 오른쪽에 체크.
/// `isMuted`: "연동 안 함"처럼 값이 없는 선택지는 흐린 글자.
public struct OptionRow: View {
    let title: String
    let note: String?
    let isSelected: Bool
    let isMuted: Bool
    let action: () -> Void

    public init(
        _ title: String,
        note: String? = nil,
        isSelected: Bool,
        isMuted: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.note = note
        self.isSelected = isSelected
        self.isMuted = isMuted
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Space.m) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .textRole(.body)
                        .foregroundStyle(isMuted ? Palette.ink3 : Palette.ink1)
                    if let note {
                        Text(note)
                            .textRole(.footnote)
                            .foregroundStyle(Palette.ink4)
                    }
                }
                Spacer(minLength: Space.s)
                if isSelected {
                    IconView(.check, size: 16)
                        .foregroundStyle(Palette.themeLine)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
            .padding(.horizontal, Space.m)
            .frame(minHeight: 54)
            .background {
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .fill(Palette.fill(isSelected ? 0.06 : 0))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.pressable)
        .animation(.soft, value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 시트 머리: 제목 + 한 줄 설명 ("SIM 2는 어느 회선인가요?" / "오늘 0.4GB 사용").
public struct SheetHeader: View {
    let title: String
    let message: String?

    public init(_ title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .textRole(.title)
                .foregroundStyle(Palette.ink1)
            if let message {
                Text(message)
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Space.m)
        .accessibilityAddTraits(.isHeader)
    }
}

extension InsettableShape {
    /// 고를 수 있는 판: `plate`, 고르면 옅은 테마색 + 테마색 1.5pt 테두리.
    public func selectionPlate(isSelected: Bool) -> some View {
        fill(Palette.plate)
            .overlay { fill(Palette.themeWash).opacity(isSelected ? 1 : 0) }
            .overlay { strokeBorder(Palette.themeLine, lineWidth: 1.5).opacity(isSelected ? 1 : 0) }
    }
}
