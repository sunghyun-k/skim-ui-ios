import Observation

// MARK: - SharedTheme

/// 앱 전역에서 공유되는 테마 싱글턴.
///
/// 읽기: `SharedTheme.value.colors.background.primary`
/// 쓰기: `SharedTheme.shared.theme = newTheme`
@Observable
public final class SharedTheme: @unchecked Sendable {
    /// 공유 인스턴스.
    public static let shared = SharedTheme()

    /// 현재 테마에 대한 편의 접근자.
    public static var value: LegendTheme { shared.theme }

    /// 현재 적용 중인 테마. 변경 시 구독 중인 뷰가 자동 업데이트된다.
    public var theme: LegendTheme = .default

    private init() {}
}
