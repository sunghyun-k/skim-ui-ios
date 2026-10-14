import SwiftUI

/// 앱마다 바꾸는 테마색 한 벌. 회색 면·글자·상태 색은 모든 앱이 같고, 이것만 다르다.
/// 앱·익스텐션 진입점에서 화면을 그리기 전에 한 번 정한다: `AccentTheme.current = .init(...)`.
public nonisolated struct AccentTheme: Sendable {
    /// 채움 (`Palette.theme`) — 주 버튼·토글·게이지·체크박스.
    public var fill: Color
    /// 선·글자 (`Palette.themeLine`) — 흰 바탕에서도 3:1 이상.
    public var line: Color
    /// `fill` 위 글자 (`Palette.onTheme`).
    public var onFill: Color

    public init(fill: Color, line: Color, onFill: Color) {
        self.fill = fill
        self.line = line
        self.onFill = onFill
    }

    /// 형광 라임 (기본). Display P3 — sRGB 라임은 어두워지면 올리브로 탁해져서, sRGB 밖 채도로 형광빛을 낸다.
    /// 밝은 색이라 위 글자는 검정. 라이트는 L .80에서 채도를 끝까지 올렸다.
    public static let lime = AccentTheme(
        fill: Color(light: 0x93D609, dark: 0xA9F413, p3: true),
        line: Color(light: 0x5EA800, dark: 0xA9F413, p3: true),
        onFill: Color(light: 0x000000, dark: 0x000000),
    )

    /// iOS 시스템 파랑. 위 글자는 흰색.
    public static let blue = AccentTheme(
        fill: Color(light: 0x007AFF, dark: 0x0A84FF),
        line: Color(light: 0x007AFF, dark: 0x0A84FF),
        onFill: Color(light: 0xFFFFFF, dark: 0xFFFFFF),
    )

    /// 지금 테마. 진입점에서 한 번 정하고 바꾸지 않는다 (렌더 스레드에서 읽는다).
    public nonisolated(unsafe) static var current: AccentTheme = .lime
}
