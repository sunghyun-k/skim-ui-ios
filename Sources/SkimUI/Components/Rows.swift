import SwiftUI

/// 누를 수 있는 줄의 오른쪽 화살표.
public struct Disclosure: View {
    public init() {}

    public var body: some View {
        IconView(.chevronRight, size: 13)
            .foregroundStyle(Palette.ink4)
    }
}

/// 누르면 아래로 내용을 펼치는 행 (자주 묻는 질문). 오른쪽 ⌄가 펼치면 위로 돈다.
/// `Disclosure`(›)는 다른 화면으로 넘어가는 행의 표시라, 제자리에서 펼치는 행은 ⌄로 구분한다.
/// `RowGroup` 안에서는 행 사이 선을 묶음이 긋고, 질문마다 따로인 카드는 행마다 `RowGroup`으로 감싼다.
/// 한 번에 하나만 펼치려면 `isExpanded`를 넘겨 부르는 쪽이 상태를 쥔다.
public struct ExpandableRow<Content: View>: View {
    let title: String
    let externalIsExpanded: Binding<Bool>?
    let content: Content

    @State private var ownIsExpanded = false
    @Environment(\.isInRowGroup) private var isInRowGroup

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.externalIsExpanded = nil
        self.content = content()
    }

    public init(_ title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.externalIsExpanded = isExpanded
        self.content = content()
    }

    private var isExpanded: Binding<Bool> {
        externalIsExpanded ?? $ownIsExpanded
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.strongOut) { isExpanded.wrappedValue.toggle() }
            } label: {
                HStack(spacing: Space.m) {
                    Text(title)
                        .textRole(.body)
                        .foregroundStyle(Palette.ink1)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: Space.s)
                    IconView(.chevronDown, size: 13)
                        .foregroundStyle(Palette.ink4)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0))
                }
                .padding(.vertical, Space.m)
                .frame(minHeight: 54)
                .rowGroupInset()
            }
            .buttonStyle(.pressableRow)
            .accessibilityValue(Text(
                isExpanded.wrappedValue
                    ? String(localized: "Expanded", bundle: .module)
                    : String(localized: "Collapsed", bundle: .module),
            ))
            if isExpanded.wrappedValue {
                content
                    .textRole(.callout)
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, Space.l)
                    .rowGroupInset()
                    .transition(.opacity)
            }
            if !isInRowGroup {
                Hairline()
            }
        }
    }
}

/// 카드 위 작은 제목 ("오늘", "이번 기간"). 카드 밖, 왼쪽 정렬.
public struct SectionTitle: View {
    let text: String
    var trailing: String?

    public init(_ text: String, trailing: String? = nil) {
        self.text = text
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text)
                .textRole(.footnote)
                .foregroundStyle(Palette.ink3)
            Spacer()
            if let trailing {
                Text(trailing)
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink4)
            }
        }
        .padding(.horizontal, Space.xs)
        .accessibilityAddTraits(.isHeader)
    }
}

/// 원형 유리 버튼 (Dial 모래시계 버튼: 흰 8% + 안쪽 12% 테두리, 34px → 42).
public struct CircleIconButtonStyle: PrimitiveButtonStyle {
    var size: CGFloat

    public init(size: CGFloat = 42) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { CircleIconButton(
            label: configuration.label,
            isPressed: $0,
            size: size,
        ) }
    }
}

private struct CircleIconButton: View {
    let label: PrimitiveButtonStyleConfiguration.Label
    let isPressed: Bool
    let size: CGFloat
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .foregroundStyle(isPressed ? Palette.ink1 : Palette.ink2)
            .frame(width: size, height: size)
            .background(Circle().fill(Palette.fill3))
            .opacity(isEnabled ? 1 : 0.3)
            .contentShape(.circle)
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.press, value: isPressed)
    }
}
