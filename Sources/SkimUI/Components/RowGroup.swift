import SwiftUI

/// 행 묶음 (iOS 그룹 inset 목록처럼): 카드 면 하나에 행을 쌓고, 행 사이에만 왼쪽을 띄운 1pt 선.
/// 안에 든 `ActionRow`·`LabeledRow`는 `isInRowGroup`을 보고 좌우 여백을 넣고 자기 아래 선을 뺀다.
/// 직접 만든 행은 같은 값을 보고 맞춘다 (`rowGroupInset()`). `if`로 빠진 행은 선도 같이 빠진다.
public struct RowGroup<Content: View>: View {
    let title: String?
    let content: Content

    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            if let title {
                SectionTitle(title)
            }
            VStack(spacing: 0) {
                Group(subviews: content) { rows in
                    ForEach(rows) { row in
                        row
                        if row.id != rows.last?.id {
                            Hairline().padding(.leading, Space.l)
                        }
                    }
                }
            }
            .environment(\.isInRowGroup, true)
            .background(CardBackground())
            .clipShape(.rect(cornerRadius: Radius.card, style: .continuous))
        }
    }
}

extension EnvironmentValues {
    /// `RowGroup` 안인지. 행이 좌우 여백·아래 선을 정하는 데 쓴다.
    @Entry public var isInRowGroup = false
}

extension View {
    /// 직접 만든 행을 `RowGroup` 안에서 맞춘다: 좌우 여백. 묶음 밖에서는 그대로.
    public func rowGroupInset() -> some View {
        modifier(RowGroupInset())
    }
}

private struct RowGroupInset: ViewModifier {
    @Environment(\.isInRowGroup) private var isInRowGroup

    func body(content: Content) -> some View {
        content.padding(.horizontal, isInRowGroup ? Space.l : 0)
    }
}
