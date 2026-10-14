import SwiftUI

/// 화면 위 안내 (동기화 실패, 권한 요청 등). 아이콘 + 문구, 필요하면 굵은 제목·버튼·닫기.
public struct Banner: View {
    let icon: Icon
    let title: String?
    let text: String
    let tone: Tone
    let actionTitle: String?
    let action: (() -> Void)?
    let onDismiss: (() -> Void)?

    public init(
        icon: Icon,
        title: String? = nil,
        text: String,
        tone: Tone = .neutral,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
    ) {
        self.icon = icon
        self.title = title
        self.text = text
        self.tone = tone
        self.actionTitle = actionTitle
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.inner, style: .continuous)
        HStack(alignment: .firstTextBaseline, spacing: Space.s) {
            IconView(icon, size: 16)
                .foregroundStyle(tone.isColored ? tone.color : Palette.ink3)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            VStack(alignment: .leading, spacing: Space.xxs) {
                if let title {
                    Text(title)
                        .textRole(.headline)
                        .foregroundStyle(Palette.ink1)
                }
                Text(text)
                    .textRole(title == nil ? .callout : .footnote)
                    .foregroundStyle(title == nil ? Palette.ink2 : Palette.ink3)
                    .fixedSize(horizontal: false, vertical: true)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.secondary(.small))
                        .padding(.top, Space.s)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let onDismiss {
                Button(action: onDismiss) {
                    IconView(.close, size: 12)
                        .foregroundStyle(Palette.ink3)
                        .frame(width: 28, height: 28)
                        .contentShape(.rect)
                }
                .buttonStyle(.pressable)
                .padding(.vertical, -6)
                .accessibilityLabel(Text(String(localized: "Close", bundle: .module)))
            }
        }
        .padding(.horizontal, Space.l)
        .padding(.vertical, Space.m)
        .background {
            shape
                .fill(tone.isColored ? tone.color.opacity(0.1) : Palette.wash)
                .overlay {
                    shape.strokeBorder(
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
