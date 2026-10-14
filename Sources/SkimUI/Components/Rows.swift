import SwiftUI

/// 누를 수 있는 줄의 오른쪽 화살표.
public struct Disclosure: View {
    public init() {}

    public var body: some View {
        IconView(.chevronRight, size: 13)
            .foregroundStyle(Palette.ink4)
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
