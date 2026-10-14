import SwiftUI

/// 버튼 높이 세 단계.
public enum ButtonSize: Sendable {
    /// 화면 아래 전체 폭 주 버튼 (50).
    case large
    /// 카드 안 버튼 (42, Dial 캡슐 34px).
    case regular
    /// 검토 카드 안 작은 버튼 (30, Dial 24px).
    case small

    public var height: CGFloat {
        switch self {
        case .large: 50
        case .regular: 42
        case .small: 30
        }
    }

    public var role: TextRole {
        self == .small ? .callout : .headline
    }

    public var padding: CGFloat {
        self == .small ? 12 : 17.5
    }
}

/// 주 버튼: 테마색(라임)으로 채운 캡슐 + 검정 글자 + 부드러운 그림자. `large`는 전체 폭.
public struct PrimaryButtonStyle: PrimitiveButtonStyle {
    var size: ButtonSize
    var isFullWidth: Bool

    /// - Parameter isFullWidth: `large`가 아닌데도 전체 폭으로 (카드 안 하나뿐인 주 행동).
    public init(size: ButtonSize = .large, isFullWidth: Bool = false) {
        self.size = size
        self.isFullWidth = isFullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { CapsuleButton(
            label: configuration.label,
            isPressed: $0,
            size: size,
            fill: .theme,
            isFullWidth: isFullWidth,
        ) }
    }
}

/// 글자색으로 채운 캡슐 (라이트 검정 · 다크 흰색) — "Apple로 계속하기"처럼 테마색이 아닌 강한 버튼. 전체 폭.
public struct InkButtonStyle: PrimitiveButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { CapsuleButton(
            label: configuration.label,
            isPressed: $0,
            size: .large,
            fill: .ink,
        ) }
    }
}

/// 되돌릴 수 없는 일을 실행하는 버튼 (계정 삭제 시트 맨 아래): 빨강으로 채운 캡슐 + 흰 글자. 전체 폭.
/// 확인 단계 안에서만 쓴다 — 설정 줄처럼 처음 누르는 자리는 `ActionRow(isDestructive:)`.
public struct DestructiveButtonStyle: PrimitiveButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { CapsuleButton(
            label: configuration.label,
            isPressed: $0,
            size: .large,
            fill: .danger,
        ) }
    }
}

/// 보조 버튼 (Dial 유리 캡슐 `bg-white/8 inset-ring-white/12`).
public struct SecondaryButtonStyle: PrimitiveButtonStyle {
    var size: ButtonSize

    public init(size: ButtonSize = .regular) {
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { CapsuleButton(
            label: configuration.label,
            isPressed: $0,
            size: size,
            fill: .glass,
        ) }
    }
}

private struct CapsuleButton: View {
    enum Fill { case theme, ink, glass, danger }

    let label: PrimitiveButtonStyleConfiguration.Label
    let isPressed: Bool
    let size: ButtonSize
    let fill: Fill
    var isFullWidth = false
    @Environment(\.isEnabled) private var isEnabled

    private var foreground: Color {
        switch fill {
        case .theme: Palette.onTheme
        case .ink: Palette.onInk
        case .glass: Palette.ink1
        case .danger: Palette.knob
        }
    }

    var body: some View {
        label
            .textRole(size.role)
            .lineLimit(1)
            .foregroundStyle(foreground)
            .padding(.horizontal, size.padding)
            .frame(
                maxWidth: size == .large || isFullWidth ? .infinity : nil,
                minHeight: size.height,
            )
            .background {
                switch fill {
                case .theme, .ink, .danger:
                    Capsule()
                        .fill(fill == .theme ? Palette.theme : fill == .ink ? Palette.ink1 : Palette
                            .red)
                        .shadow(
                            color: Palette.buttonShadow.opacity(isEnabled ? 1 : 0),
                            radius: 6,
                            y: 3,
                        )
                case .glass:
                    Capsule().fill(Palette.fill3)
                }
            }
            .opacity(isEnabled ? 1 : 0.35)
            .contentShape(.capsule)
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.press, value: isPressed)
            .animation(.soft, value: isEnabled)
    }
}

/// 화면 아래에 떠 있는 주 버튼: 내용이 밑으로 스크롤되는 자리 (등록 단계 "다음"). 테마색을 입힌 Liquid Glass 캡슐, 전체 폭.
/// 꺼지면 색 없는 유리. 내용 층(카드 안)에는 쓰지 않는다 — 거기는 `.primary`. iOS 26 미만은 `.primary`와 같다.
/// `.floatingInk`: 검정을 입힌 유리 (시작 화면 "Apple로 계속하기"). iOS 26 미만은 `.ink`.
public struct FloatingButtonStyle: PrimitiveButtonStyle {
    public enum Tint: Sendable { case theme, ink }

    let tint: Tint

    public init(tint: Tint = .theme) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { isPressed in
            if #available(iOS 26, *) {
                FloatingGlassButton(label: configuration.label, tint: tint)
            } else {
                CapsuleButton(
                    label: configuration.label,
                    isPressed: isPressed,
                    size: .large,
                    fill: tint == .theme ? .theme : .ink,
                )
            }
        }
    }
}

@available(iOS 26, *)
private struct FloatingGlassButton: View {
    let label: PrimitiveButtonStyleConfiguration.Label
    let tint: FloatingButtonStyle.Tint
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .textRole(ButtonSize.large.role)
            .lineLimit(1)
            .foregroundStyle(isEnabled ? (tint == .theme ? Palette.onTheme : Palette.onInk) :
                Palette.ink4)
            .padding(.horizontal, ButtonSize.large.padding)
            .frame(maxWidth: .infinity, minHeight: ButtonSize.large.height)
            .contentShape(.capsule)
            .glassEffect(
                isEnabled ? .regular.tint(tint == .theme ? Palette.theme : Palette.ink1)
                    .interactive() : .regular,
                in: .capsule,
            )
            .animation(.soft, value: isEnabled)
    }
}

/// 글자만 있는 버튼 ("직접 입력", "나중에"). 누르면 흐려진다.
public struct QuietButtonStyle: PrimitiveButtonStyle {
    var color: Color

    public init(color: Color = Palette.ink3) {
        self.color = color
    }

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { isPressed in
            configuration.label
                .textRole(.callout)
                .foregroundStyle(color)
                .opacity(isPressed ? 0.5 : 1)
                .contentShape(.rect)
                .animation(.press, value: isPressed)
        }
    }
}

extension PrimitiveButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }

    public static func primary(_ size: ButtonSize, fullWidth: Bool = false) -> PrimaryButtonStyle {
        PrimaryButtonStyle(size: size, isFullWidth: fullWidth)
    }
}

extension PrimitiveButtonStyle where Self == DestructiveButtonStyle {
    public static var destructive: DestructiveButtonStyle {
        DestructiveButtonStyle()
    }
}

extension PrimitiveButtonStyle where Self == InkButtonStyle {
    public static var ink: InkButtonStyle {
        InkButtonStyle()
    }
}

extension PrimitiveButtonStyle where Self == SecondaryButtonStyle {
    public static var secondary: SecondaryButtonStyle {
        SecondaryButtonStyle()
    }

    public static var secondaryCompact: SecondaryButtonStyle {
        SecondaryButtonStyle(size: .small)
    }

    public static func secondary(_ size: ButtonSize)
        -> SecondaryButtonStyle
    {
        SecondaryButtonStyle(size: size)
    }
}

extension PrimitiveButtonStyle where Self == FloatingButtonStyle {
    public static var floating: FloatingButtonStyle {
        FloatingButtonStyle()
    }

    public static var floatingInk: FloatingButtonStyle {
        FloatingButtonStyle(tint: .ink)
    }
}

extension PrimitiveButtonStyle where Self == QuietButtonStyle {
    public static var quiet: QuietButtonStyle {
        QuietButtonStyle()
    }
}

/// `.pressable` — 누르면 0.96으로 줄어든다 (.14s ease-out-strong). 모양은 바꾸지 않는다.
public struct PressableStyle: PrimitiveButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { isPressed in
            configuration.label
                .contentShape(.rect)
                .scaleEffect(isPressed ? 0.96 : 1)
                .animation(.press, value: isPressed)
        }
    }
}

extension PrimitiveButtonStyle where Self == PressableStyle {
    public static var pressable: PressableStyle {
        PressableStyle()
    }
}

/// 카드 전체를 누르는 버튼 — 큰 면이라 0.96이면 출렁거려 보여서 0.985.
public struct PressableCardStyle: PrimitiveButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PressableButton(configuration) { isPressed in
            configuration.label
                .scaleEffect(isPressed ? 0.985 : 1)
                .brightness(isPressed ? -0.02 : 0)
                .animation(.press, value: isPressed)
        }
    }
}

extension PrimitiveButtonStyle where Self == PressableCardStyle {
    public static var pressableCard: PressableCardStyle {
        PressableCardStyle()
    }
}

extension View {
    /// 시스템 토글의 켜짐 색. 앱 `tint`가 글자색(`ink1`)이라 그대로 두면 다크에서 흰 홈 위 흰 손잡이가 된다.
    public func switchTint() -> some View {
        tint(Palette.theme)
    }
}

extension View {
    /// 버튼 글자 자리에 스피너 (기다리는 동안). 크기가 바뀌지 않게 글자는 자리만 남기고 스피너를 겹친다.
    /// `tint`는 버튼 글자색 (`.primary`·`.floating`은 `onTheme`, `.ink`·`.floatingInk`는 `onInk`).
    public func busyLabel(_ isBusy: Bool, tint: Color = Palette.ink3) -> some View {
        opacity(isBusy ? 0 : 1)
            .overlay {
                if isBusy {
                    ProgressView().tint(tint)
                }
            }
    }
}
