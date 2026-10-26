import SwiftUI

public extension View {
    /// 화면 가장자리에서 시스템이 정한 여백만큼 띄운다. 고정 `Space.gutter` 대신 쓴다.
    ///
    /// 여백은 기기·방향에 따라 16 또는 20이고, 접힌 iPhone Duo 에서는 막대 쪽이 0, 반대쪽이 20처럼 좌우가 다르다.
    /// 고정 여백은 안전 영역에서 재므로 이런 기기에서 어긋난다. iOS·macOS 27.1 전에는 `Space.gutter` 로 띄운다.
    @ViewBuilder
    func systemMargins(_ edges: Edge.Set = .horizontal) -> some View {
        if #available(iOS 27.1, macOS 27.1, *) {
            contentMargins(for: .container, edges: edges)
        } else {
            padding(edges, Space.gutter)
        }
    }

    /// 스크롤 뷰의 내용 여백을 시스템 여백으로 준다(가로 캐러셀). 스크롤은 화면 끝까지 닿고 내용만 띄운다.
    ///
    /// 좌우 여백이 다를 수 있어 앞·뒤를 따로 읽는다. 27.1 전에는 `Space.gutter`.
    func systemScrollMargins(_ edges: Edge.Set = .horizontal) -> some View {
        modifier(SystemScrollMargins(edges: edges))
    }
}

private struct SystemScrollMargins: ViewModifier {
    let edges: Edge.Set
    @State private var margins = EdgeInsets(top: Space.gutter, leading: Space.gutter, bottom: Space.gutter, trailing: Space.gutter)

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 27.1, macOS 27.1, *) {
                content.onGeometryChange(for: EdgeInsets.self) { proxy in
                    proxy.contentMargins(for: .container, edges: edges)
                } action: { margins = $0 }
            } else {
                content
            }
        }
        .contentMargins(.top, edges.contains(.top) ? margins.top : 0, for: .scrollContent)
        .contentMargins(.leading, edges.contains(.leading) ? margins.leading : 0, for: .scrollContent)
        .contentMargins(.bottom, edges.contains(.bottom) ? margins.bottom : 0, for: .scrollContent)
        .contentMargins(.trailing, edges.contains(.trailing) ? margins.trailing : 0, for: .scrollContent)
    }
}
