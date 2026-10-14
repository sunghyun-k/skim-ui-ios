import SwiftUI

/// 위에 선을 두고 두 칸으로 나눈 작은 값 ("남은 양 · 이번 달 5.2GB | 오늘 사용 0.2GB").
public struct StatSplit: View {
    public struct Item: Hashable {
        public let label: String
        public let value: String
        public let valueColor: Color

        /// `valueColor`: 얼마 안 남았거나 다 썼을 때 값만 상태 색 (`Tone.color`).
        public init(label: String, value: String, valueColor: Color = Palette.ink1) {
            self.label = label
            self.value = value
            self.valueColor = valueColor
        }
    }

    let items: [Item]

    public init(_ items: [Item]) {
        self.items = items
    }

    public var body: some View {
        VStack(spacing: Space.m) {
            Hairline()
            // 나란히 한 줄에 안 들어가면(가장 큰 글자들) 위아래로 쌓는다 — 값이 "5.19G / B"로 끊겼다.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        if index > 0 {
                            Rectangle().fill(Palette.hair).frame(width: 1).padding(
                                .trailing,
                                Space.m,
                            )
                        }
                        cell(item)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: Space.m) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        cell(item)
                    }
                }
            }
        }
    }

    private func cell(_ item: Item) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.label)
                .textRole(.caption)
                .foregroundStyle(Palette.ink3)
            Text(item.value)
                .textRole(.title)
                .foregroundStyle(item.valueColor)
                .contentTransition(.numericText())
                .animation(.roll, value: item.value)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// 회선 카드의 사용량 줄: "5.2GB 남음" ……… "월 11GB 중" + 얇은 게이지.
/// 무제한이면 게이지 대신 `footnote` ("오늘 1.9GB"), SIM 미연동이면 값 "—".
public struct MeterRow: View {
    let value: String
    let caption: String
    let progress: Double?
    let color: Color
    let footnote: String?
    let valueColor: Color
    let valueIcon: Icon?

    public init(
        value: String,
        caption: String,
        progress: Double? = nil,
        color: Color = Palette.theme,
        footnote: String? = nil,
        valueColor: Color = Palette.ink1,
        valueIcon: Icon? = nil,
    ) {
        self.valueColor = valueColor
        self.valueIcon = valueIcon
        self.value = value
        self.caption = caption
        self.progress = progress
        self.color = color
        self.footnote = footnote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            // 한 줄에 안 들어가면(가장 큰 글자들) 두 줄로 쌓는다 — "6.39G… 월 11GB…"로 잘렸다.
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    valueText
                    Spacer(minLength: Space.s)
                    captionText
                }
                VStack(alignment: .leading, spacing: 2) {
                    valueText
                    captionText
                }
            }
            .lineLimit(1)
            if let progress {
                LinearGauge(progress: progress, fill: color, height: 8)
            } else if let footnote {
                Text(footnote)
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink2)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var valueText: some View {
        HStack(spacing: 4) {
            if let valueIcon {
                IconView(valueIcon, size: 18)
            }
            Text(value)
                .textRole(.title)
                .contentTransition(.numericText())
        }
        .foregroundStyle(valueColor)
    }

    private var captionText: some View {
        Text(caption)
            .textRole(.footnote)
            .foregroundStyle(Palette.ink3)
    }
}

/// 라벨 열 + 값 + (선택) 오른쪽 글자 버튼. 회선 상세·등록 확인의 줄 ("할인 종료  2026년 12월 31일 · D-74  [수정]").
/// 아래에 1pt 선. 라벨 열은 88pt 고정 — 줄마다 값이 같은 세로선에서 시작한다.
public struct LabeledRow: View {
    let label: String
    let value: String
    let note: String?
    let isMuted: Bool
    let actionTitle: String?
    let action: (() -> Void)?

    @ScaledMetric(relativeTo: .footnote) private var labelWidth: CGFloat = 88
    @Environment(\.isInRowGroup) private var isInRowGroup

    /// - Parameters:
    ///   - note: 값 아래 작은 한 줄 ("10.9부터 측정 · 그 전은 빠져 있음").
    ///   - isMuted: "입력 안 함", "회선 연동 안 됨"처럼 값이 없을 때.
    public init(
        _ label: String,
        value: String,
        note: String? = nil,
        isMuted: Bool = false,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.label = label
        self.value = value
        self.note = note
        self.isMuted = isMuted
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Space.m) {
                Text(label)
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink3)
                    .frame(width: labelWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .textRole(.callout)
                        .foregroundStyle(isMuted ? Palette.ink4 : Palette.ink1)
                    if let note {
                        Text(note)
                            .textRole(.caption)
                            .foregroundStyle(Palette.ink4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(QuietButtonStyle(color: Palette.ink2))
                }
            }
            .padding(.vertical, 13)
            .frame(minHeight: 48)
            .rowGroupInset()
            if !isInRowGroup {
                Hairline()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// 두 줄 행 + 아래 1pt 선 (`RowGroup` 안에서는 선 대신 묶음이 나눈다): "해지한 요금제로 표시 / 요금제 정보는 보관합니다" ……… [토글·값·›].
/// `isDestructive`: 지우는·나가는 행 (로그아웃·삭제) — 제목을 빨강. `leading`: 제목 앞 표식 (로그인 수단 로고).
public struct ActionRow<Leading: View, Trailing: View>: View {
    let title: String
    let subtitle: String?
    let isDestructive: Bool
    let leading: Leading
    let trailing: Trailing

    @Environment(\.isInRowGroup) private var isInRowGroup

    public init(
        _ title: String,
        subtitle: String? = nil,
        isDestructive: Bool = false,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Space.m) {
                leading
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .textRole(.body)
                        .foregroundStyle(isDestructive ? Palette.red : Palette.ink1)
                    if let subtitle {
                        Text(subtitle)
                            .textRole(.footnote)
                            .foregroundStyle(Palette.ink4)
                    }
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: Space.s)
                trailing
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink3)
            }
            .padding(.vertical, Space.m)
            .frame(minHeight: 54)
            .rowGroupInset()
            if !isInRowGroup {
                Hairline()
            }
        }
        .contentShape(.rect)
    }
}

extension ActionRow where Leading == EmptyView {
    public init(
        _ title: String,
        subtitle: String? = nil,
        isDestructive: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.init(
            title,
            subtitle: subtitle,
            isDestructive: isDestructive,
            leading: { EmptyView() },
            trailing: trailing,
        )
    }
}

/// 옅은 판 안내 한 줄 + (선택) 오른쪽 버튼 ("회선에 연동하면 남은 양이 보입니다  [연동]", 프리셋 안내).
public struct Notice: View {
    let text: String
    let actionTitle: String?
    let action: (() -> Void)?

    public init(_ text: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous)
        HStack(spacing: Space.m) {
            Text(text)
                .textRole(.footnote)
                .foregroundStyle(Palette.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.secondary(.small))
            }
        }
        .padding(.horizontal, Space.m)
        .padding(.vertical, actionTitle == nil ? 10 : 7)
        .frame(minHeight: 44)
        .background(shape.fill(Palette.fill3))
    }
}
