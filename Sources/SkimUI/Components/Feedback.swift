import SwiftUI

/// 화면 위 한 줄 안내 (동기화 실패 등).
public struct Banner: View {
    let icon: Icon
    let text: String
    let tone: Tone

    public init(icon: Icon, text: String, tone: Tone = .neutral) {
        self.icon = icon
        self.text = text
        self.tone = tone
    }

    public var body: some View {
        HStack(spacing: Space.s) {
            IconView(icon, size: 16)
                .foregroundStyle(tone.color)
            Text(text)
                .textRole(.callout)
                .foregroundStyle(Palette.ink2)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Space.l)
        .padding(.vertical, Space.m)
        .background {
            RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
                .fill(tone.isColored ? tone.color.opacity(0.1) : Palette.wash)
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
                        .strokeBorder(
                            tone.isColored ? tone.color.opacity(0.35) : Palette.hair,
                            lineWidth: 1,
                        )
                }
        }
    }
}

/// 빈 화면. 큰 아이콘 원판 + 제목 + 설명 + (선택) 버튼.
public struct EmptyState<Actions: View>: View {
    let icon: Icon
    let title: String
    let message: String?
    let actions: Actions

    public init(
        icon: Icon,
        title: String,
        message: String? = nil,
        @ViewBuilder actions: () -> Actions = { EmptyView() },
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: Space.l) {
            IconView(icon, size: 30)
                .foregroundStyle(Palette.ink2)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Palette.fill(0.06)).insetRing(Circle(), 0.1))
            VStack(spacing: Space.xs) {
                Text(title)
                    .textRole(.title)
                    .foregroundStyle(Palette.ink1)
                if let message {
                    Text(message)
                        .textRole(.callout)
                        .foregroundStyle(Palette.ink3)
                }
            }
            .multilineTextAlignment(.center)
            actions
        }
        .padding(Space.xxl)
        .frame(maxWidth: .infinity)
    }
}
