import SwiftUI

/// 상태 칩 ("D-84", "D-3"). 여유·중립은 무채색, 주의는 테두리만, 경고는 채움.
/// 자리표시(`.redacted(reason: .placeholder)`, `.skeleton`)일 때는 상태를 모르므로 무채색.
public struct ToneChip: View {
    let text: String
    let tone: Tone
    var compact: Bool
    @Environment(\.redactionReasons) private var redactionReasons

    private var shownTone: Tone {
        redactionReasons.contains(.placeholder) ? .neutral : tone
    }

    /// `compact`: 위젯 머리처럼 좁은 곳 — 여백을 줄인다.
    public init(_ text: String, tone: Tone, compact: Bool = false) {
        self.text = text
        self.tone = tone
        self.compact = compact
    }

    public var body: some View {
        Text(text)
            .textRole(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, compact ? 6.5 : 9)
            .padding(.vertical, compact ? 2.5 : 4.5)
            .foregroundStyle(foreground)
            .background {
                Capsule().fill(background)
            }
            .overlay {
                Capsule().strokeBorder(border, lineWidth: 1)
            }
    }

    private var foreground: Color {
        switch shownTone {
        case .alert: Palette.onInk
        case .caution: Palette.cautionInk
        default: Palette.ink2
        }
    }

    private var background: Color {
        switch shownTone {
        case .alert: Palette.red
        case .caution: Palette.yellow.opacity(0.12)
        default: Palette.wash
        }
    }

    private var border: Color {
        switch shownTone {
        case .alert: .clear
        case .caution: Palette.yellow.opacity(0.45)
        default: Palette.hair
        }
    }
}

/// 큰 숫자 + 작은 단위 ("340" "MB"). Dial 타이머처럼 단위는 숫자의 약 0.3배, ink3.
/// 숫자는 톤과 상관없이 늘 `ink1` — 톤은 카드 면·칩·게이지가 보여 준다. 값이 바뀌면 숫자가 굴러간다.
public struct ValueText: View {
    let value: String
    let unit: String?
    var role: TextRole

    public init(_ value: String, unit: String? = nil, role: TextRole = .hero) {
        self.value = value
        self.unit = unit
        self.role = role
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(value)
                .textRole(role)
                .foregroundStyle(Palette.ink1)
                .contentTransition(.numericText())
                .animation(.roll, value: value)
            if let unit, !unit.isEmpty {
                Text(unit)
                    .textRole(role == .display || role == .hero || role == .largeTitle ? .unit :
                        .footnote)
                    .foregroundStyle(Palette.ink3)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .combine)
    }
}
