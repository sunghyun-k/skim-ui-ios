import SwiftUI

extension View {
    /// 화면 가장자리에서 시스템이 정한 여백만큼 띄운다. 고정 여백(`Space.gutter`) 대신 쓴다.
    ///
    /// 여백은 기기·방향에 따라 16 또는 20이고, 접힌 iPhone Duo 에서는 막대 쪽이 0, 반대쪽이 20처럼 좌우가 다르다.
    /// 고정 여백은 안전 영역에서 재므로 이런 기기에서 어긋난다. iOS·macOS 27.1 전에는 16 으로 띄운다.
    @ViewBuilder
    public func systemMargins(_ edges: Edge.Set = .horizontal) -> some View {
        if #available(iOS 27.1, macOS 27.1, *) {
            contentMargins(for: .container, edges: edges)
        } else {
            padding(edges, SystemMargin.fallback)
        }
    }

    /// 스크롤 뷰의 내용 여백을 시스템 여백으로 준다(가로 캐러셀). 스크롤은 화면 끝까지 닿고 내용만 띄운다.
    ///
    /// 좌우 여백이 다를 수 있어 앞·뒤를 따로 읽는다. 27.1 전에는 16.
    public func systemScrollMargins(_ edges: Edge.Set = .horizontal) -> some View {
        modifier(SystemScrollMargins(edges: edges))
    }

    /// 화면 전체를 쓰는 화면(영상·사진 뷰어처럼 막대를 숨긴 화면)의 컨테이너. 안의 막대가
    /// `systemMarginsAvoidingOcclusion()` 으로 가로 여백을 정할 수 있게, 가로 안전 영역을 무시하고 안전 영역·시스템 여백·
    /// 가리는 영역(`ReservedRegion` `.occlusion`: 카메라, Dynamic Island)을 막대에 알린다.
    ///
    /// iPhone Duo 커버 화면은 시스템 막대 쪽 84pt 가 통째로 안전 영역이라(상태 막대를 숨겨도 남는다) 안전 영역을 따르면
    /// 세로 폭 466pt 중 362pt 만 쓴다. 실제로 가리는 것은 모서리 카메라(84×82pt) 하나다.
    public func occlusionAwareLayout() -> some View {
        modifier(OcclusionAwareLayout())
    }

    /// `occlusionAwareLayout()` 안의 막대 하나에 가로 시스템 여백을 준다. 안전 영역 띠 안에 가리는 영역이 있는 변은 안전 영역
    /// 대신 이 막대와 세로로 겹치는 영역만 피하고(+8pt), 겹치지 않으면 화면 가장자리에서 반대쪽 변의 시스템 여백만큼 띄운다.
    /// 가리는 영역이 없는 변(가로 iPhone 의 둥근 모서리 쪽)은 안전 영역 + 시스템 여백. 컨테이너 밖에서는 `systemMargins()`.
    public func systemMarginsAvoidingOcclusion() -> some View {
        modifier(OcclusionAvoidingMargins())
    }
}

extension GeometryProxy {
    /// 이 뷰가 놓인 컨테이너의 가로 시스템 여백(안전 영역 안쪽에서 잰다). 27.1 전에는 16.
    public var systemMargins: EdgeInsets {
        if #available(iOS 27.1, macOS 27.1, *) {
            return contentMargins(for: .container, edges: .horizontal)
        }
        return EdgeInsets(
            top: 0,
            leading: SystemMargin.fallback,
            bottom: 0,
            trailing: SystemMargin.fallback,
        )
    }
}

enum SystemMargin {
    /// iOS·macOS 27.1 전, 시스템 여백을 읽을 수 없을 때.
    static let fallback: CGFloat = 16
}

private struct SystemScrollMargins: ViewModifier {
    let edges: Edge.Set
    @State private var margins = EdgeInsets(
        top: SystemMargin.fallback,
        leading: SystemMargin.fallback,
        bottom: SystemMargin.fallback,
        trailing: SystemMargin.fallback,
    )

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
        .contentMargins(
            .leading,
            edges.contains(.leading) ? margins.leading : 0,
            for: .scrollContent,
        )
        .contentMargins(.bottom, edges.contains(.bottom) ? margins.bottom : 0, for: .scrollContent)
        .contentMargins(
            .trailing,
            edges.contains(.trailing) ? margins.trailing : 0,
            for: .scrollContent,
        )
    }
}

// MARK: 가리는 영역을 피하는 여백

/// `occlusionAwareLayout()` 이 막대에 알리는 값. 좌우는 화면 기준(왼쪽·오른쪽)이다: 가리는 영역은 기기에 붙어 있어
/// 오른쪽에서 왼쪽으로 쓰는 언어에서도 뒤집히지 않는다.
struct OcclusionLayout: Equatable {
    var safeLeft: CGFloat = 0
    var safeRight: CGFloat = 0
    var marginLeft: CGFloat = SystemMargin.fallback
    var marginRight: CGFloat = SystemMargin.fallback
    /// 창 좌표.
    var occlusions: [CGRect] = []
}

extension EnvironmentValues {
    @Entry var occlusionLayout: OcclusionLayout?
}

private struct OcclusionAwareLayout: ViewModifier {
    @State private var layout = OcclusionLayout()
    @Environment(\.layoutDirection) private var layoutDirection

    func body(content: Content) -> some View {
        // 바깥 ZStack 은 안전 영역 안에 두고 안전 영역·시스템 여백을 잰다. 안은 가로 안전 영역을 무시한다.
        ZStack {
            content
                .environment(\.occlusionLayout, layout)
                .ignoresSafeArea(edges: .horizontal)
        }
        .onGeometryChange(for: [CGFloat].self) { proxy in
            let safe = proxy.safeAreaInsets
            let margins = proxy.systemMargins
            return [safe.leading, safe.trailing, margins.leading, margins.trailing]
        } action: { values in
            let rtl = layoutDirection == .rightToLeft
            layout.safeLeft = rtl ? values[1] : values[0]
            layout.safeRight = rtl ? values[0] : values[1]
            layout.marginLeft = rtl ? values[3] : values[2]
            layout.marginRight = rtl ? values[2] : values[3]
        }
        .background {
            // `ignoresSafeArea` 뒤의 `onGeometryChange` 는 넓어지기 전 크기·영역을 받아, 읽는 뷰를 따로 넓힌다.
            GeometryReader { proxy in
                Color.clear.onChange(of: Self.occlusions(proxy), initial: true) { _, frames in
                    layout.occlusions = frames
                }
            }
            .ignoresSafeArea()
        }
    }

    private static func occlusions(_ proxy: GeometryProxy) -> [CGRect] {
        guard #available(iOS 27.1, macOS 27.1, *) else { return [] }
        let origin = proxy.frame(in: .global).origin
        return proxy.reservedRegions(kind: .occlusion, layoutDirectionBehavior: .fixed)
            .filter(\.isActive)
            .map { $0.frame.offsetBy(dx: origin.x, dy: origin.y) }
    }
}

private struct OcclusionAvoidingMargins: ViewModifier {
    @Environment(\.occlusionLayout) private var layout
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var frame: CGRect = .zero

    private static let gap: CGFloat = 8

    func body(content: Content) -> some View {
        if let layout {
            let left = inset(layout, left: true)
            let right = inset(layout, left: false)
            let rtl = layoutDirection == .rightToLeft
            content
                .padding(.leading, rtl ? right : left)
                .padding(.trailing, rtl ? left : right)
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame = $0 }
        } else {
            content.systemMargins()
        }
    }

    private func inset(_ layout: OcclusionLayout, left: Bool) -> CGFloat {
        let safe = left ? layout.safeLeft : layout.safeRight
        let margin = left ? layout.marginLeft : layout.marginRight
        guard safe > 0, frame.width > 0 else { return safe + margin }
        // 그 변의 안전 영역 띠 안에 있는 가리는 영역.
        let strip = left
            ? CGRect(
                x: frame.minX,
                y: -.greatestFiniteMagnitude / 2,
                width: safe,
                height: .greatestFiniteMagnitude,
            )
            : CGRect(
                x: frame.maxX - safe,
                y: -.greatestFiniteMagnitude / 2,
                width: safe,
                height: .greatestFiniteMagnitude,
            )
        let regions = layout.occlusions.filter { $0.intersects(strip) }
        guard !regions.isEmpty else { return safe + margin }
        // 이 변의 시스템 여백은 시스템 막대 쪽이라 0 으로 온다. 가장자리에서는 반대쪽 변의 시스템 여백만큼 띄운다.
        let edgeMargin = max(layout.marginLeft, layout.marginRight)
        let clearance = regions
            .filter { $0.minY < frame.maxY && $0.maxY > frame.minY }
            .map { left ? $0.maxX - frame.minX : frame.maxX - $0.minX }
            .max() ?? 0
        return max(edgeMargin, clearance > 0 ? clearance + Self.gap : 0)
    }
}
