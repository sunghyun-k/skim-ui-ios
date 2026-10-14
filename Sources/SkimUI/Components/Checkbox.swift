import SwiftUI

/// 체크박스 토글 (`Toggle(...).toggleStyle(.check)`). 끄면 옅은 테두리, 켜면 테마색으로 꽉 차고 체크.
/// 얇은 선이 아니라 면이라 사진·아이콘 위에서도 또렷하다. 글자가 있으면 오른쪽에 `body`로.
public struct CheckToggleStyle: ToggleStyle {
    var size: CGFloat

    public init(size: CGFloat = 22) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: Space.m) {
                CheckBox(isOn: configuration.isOn, size: size)
                configuration.label
                    .textRole(.body)
                    .foregroundStyle(Palette.ink1)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.pressable)
        .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
    }
}

extension ToggleStyle where Self == CheckToggleStyle {
    public static var check: CheckToggleStyle {
        CheckToggleStyle()
    }

    public static func check(size: CGFloat) -> CheckToggleStyle {
        CheckToggleStyle(size: size)
    }
}

/// 체크 표시만 (토글 없이 선택 상태를 보일 때).
public struct CheckBox: View {
    let isOn: Bool
    let size: CGFloat
    @Environment(\.isEnabled) private var isEnabled

    public init(isOn: Bool, size: CGFloat = 22) {
        self.isOn = isOn
        self.size = size
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
        ZStack {
            shape.fill(Palette.plate)
            shape.strokeBorder(Palette.fill(0.3), lineWidth: 1.5)
                .opacity(isOn ? 0 : 1)
            shape.fill(Palette.theme)
                .scaleEffect(isOn ? 1 : 0.6)
                .opacity(isOn ? 1 : 0)
            IconView(.check, size: size * 0.68)
                .foregroundStyle(Palette.onTheme)
                .scaleEffect(isOn ? 1 : 0.4)
                .opacity(isOn ? 1 : 0)
        }
        .frame(width: size, height: size)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.strongOut, value: isOn)
        .accessibilityHidden(true)
    }
}
