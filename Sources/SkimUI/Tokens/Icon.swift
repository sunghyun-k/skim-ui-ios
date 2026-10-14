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
    public static let app = Icon("app", bundle: .module)
    public static let apps = Icon("apps", bundle: .module)
    public static let arrowRight = Icon("arrow.right", bundle: .module)
    public static let arrowUpRight = Icon("arrow.up.right", bundle: .module)
    public static let bell = Icon("bell", bundle: .module)
    public static let bolt = Icon("bolt", bundle: .module)
    public static let calendar = Icon("calendar", bundle: .module)
    public static let chart = Icon("chart", bundle: .module)
    public static let check = Icon("check", bundle: .module)
    public static let checklist = Icon("checklist", bundle: .module)
    public static let chevronDown = Icon("chevron.down", bundle: .module)
    public static let chevronLeft = Icon("chevron.left", bundle: .module)
    public static let chevronRight = Icon("chevron.right", bundle: .module)
    public static let clock = Icon("clock", bundle: .module)
    public static let close = Icon("close", bundle: .module)
    public static let copy = Icon("copy", bundle: .module)
    public static let crown = Icon("crown", bundle: .module)
    public static let doc = Icon("doc", bundle: .module)
    public static let download = Icon("download", bundle: .module)
    public static let envelope = Icon("envelope", bundle: .module)
    public static let exclamation = Icon("exclamation", bundle: .module)
    public static let eye = Icon("eye", bundle: .module)
    public static let folder = Icon("folder", bundle: .module)
    public static let folderPlus = Icon("folder.plus", bundle: .module)
    public static let gear = Icon("gear", bundle: .module)
    public static let globe = Icon("globe", bundle: .module)
    public static let hand = Icon("hand", bundle: .module)
    public static let house = Icon("house", bundle: .module)
    public static let infinity = Icon("infinity", bundle: .module)
    public static let info = Icon("info", bundle: .module)
    public static let link = Icon("link", bundle: .module)
    public static let lock = Icon("lock", bundle: .module)
    public static let minus = Icon("minus", bundle: .module)
    public static let moon = Icon("moon", bundle: .module)
    public static let more = Icon("more", bundle: .module)
    public static let pencil = Icon("pencil", bundle: .module)
    public static let photo = Icon("photo", bundle: .module)
    public static let play = Icon("play", bundle: .module)
    public static let plus = Icon("plus", bundle: .module)
    public static let question = Icon("question", bundle: .module)
    public static let refresh = Icon("refresh", bundle: .module)
    public static let search = Icon("search", bundle: .module)
    public static let share = Icon("share", bundle: .module)
    public static let sliders = Icon("sliders", bundle: .module)
    public static let sort = Icon("sort", bundle: .module)
    public static let sparkle = Icon("sparkle", bundle: .module)
    public static let star = Icon("star", bundle: .module)
    public static let stop = Icon("stop", bundle: .module)
    public static let swap = Icon("swap", bundle: .module)
    public static let tap = Icon("tap", bundle: .module)
    public static let trash = Icon("trash", bundle: .module)
    public static let warning = Icon("warning", bundle: .module)
    public static let widget = Icon("widget", bundle: .module)

    /// SkimUI가 가진 아이콘 전부 (갤러리용).
    public static let builtIn: [Icon] = [
        .app,
        .apps,
        .arrowRight,
        .arrowUpRight,
        .bell,
        .bolt,
        .calendar,
        .chart,
        .check,
        .checklist,
        .chevronDown,
        .chevronLeft,
        .chevronRight,
        .clock,
        .close,
        .copy,
        .crown,
        .doc,
        .download,
        .envelope,
        .exclamation,
        .eye,
        .folder,
        .folderPlus,
        .gear,
        .globe,
        .hand,
        .house,
        .infinity,
        .info,
        .link,
        .lock,
        .minus,
        .moon,
        .more,
        .pencil,
        .photo,
        .play,
        .plus,
        .question,
        .refresh,
        .search,
        .share,
        .sliders,
        .sort,
        .sparkle,
        .star,
        .stop,
        .swap,
        .tap,
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
