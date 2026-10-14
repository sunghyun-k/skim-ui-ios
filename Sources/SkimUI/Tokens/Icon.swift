import SwiftUI

/// 직접 그린 아이콘 (24pt 격자 SVG, 템플릿 렌더링). SF Symbols 대신 쓴다 — 굵은 채움 도형, 둥근 모서리.
/// 원본은 `Tools/icons.py`. 앱 고유 아이콘은 앱 에셋에 같은 규칙으로 그려 `extension Icon`에 더한다:
/// `static let sim = Icon("sim", bundle: .module)`.
public struct Icon: Hashable, @unchecked Sendable {
    public let name: String
    public let bundle: Bundle

    public init(_ name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

    public var image: Image {
        Image(name, bundle: bundle)
    }
}

extension Icon {
    public static let arrowUpRight = Icon("arrow.up.right", bundle: .module)
    public static let bell = Icon("bell", bundle: .module)
    public static let calendar = Icon("calendar", bundle: .module)
    public static let chart = Icon("chart", bundle: .module)
    public static let check = Icon("check", bundle: .module)
    public static let chevronLeft = Icon("chevron.left", bundle: .module)
    public static let chevronRight = Icon("chevron.right", bundle: .module)
    public static let close = Icon("close", bundle: .module)
    public static let exclamation = Icon("exclamation", bundle: .module)
    public static let info = Icon("info", bundle: .module)
    public static let link = Icon("link", bundle: .module)
    public static let minus = Icon("minus", bundle: .module)
    public static let pencil = Icon("pencil", bundle: .module)
    public static let plus = Icon("plus", bundle: .module)
    public static let search = Icon("search", bundle: .module)
    public static let sliders = Icon("sliders", bundle: .module)
    public static let sparkle = Icon("sparkle", bundle: .module)
    public static let trash = Icon("trash", bundle: .module)
    public static let warning = Icon("warning", bundle: .module)
    public static let widget = Icon("widget", bundle: .module)

    /// SkimUI가 가진 아이콘 전부 (갤러리용).
    public static let builtIn: [Icon] = [
        .arrowUpRight,
        .bell,
        .calendar,
        .chart,
        .check,
        .chevronLeft,
        .chevronRight,
        .close,
        .exclamation,
        .info,
        .link,
        .minus,
        .pencil,
        .plus,
        .search,
        .sliders,
        .sparkle,
        .trash,
        .warning,
        .widget,
    ]
}

extension Label where Title == Text, Icon == Image {
    /// `Label("알림", icon: .bell)` — 탭 바·메뉴·툴바에서 시스템 모양 그대로 쓰인다.
    public init(_ title: String, icon: SkimUI.Icon) {
        self.init { Text(title) } icon: { icon.image }
    }

    public init(_ title: LocalizedStringResource, icon: SkimUI.Icon) {
        self.init { Text(title) } icon: { icon.image }
    }
}

/// 아이콘 한 개를 글자 크기에 맞춰 그린다.
public struct IconView: View {
    let icon: Icon
    let size: CGFloat

    public init(_ icon: Icon, size: CGFloat = 18) {
        self.icon = icon
        self.size = size
    }

    public var body: some View {
        icon.image
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
