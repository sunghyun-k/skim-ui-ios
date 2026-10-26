import SwiftUI

/// 간격 (4pt 격자).
public enum Space {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 12
    public static let l: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 28
    public static let xxxl: CGFloat = 40
    /// 화면 좌우 여백의 대체값. 화면 가장자리에는 `systemMargins()`·`systemScrollMargins()` 를 쓴다(기기마다 다름).
    public static let gutter: CGFloat = 16
}

/// 모서리. 전부 연속 곡률(`.continuous`). 작은 건 캡슐·원. Dial px × 1.25.
public enum Radius {
    /// 카드·행 묶음. iOS 26 그룹 목록에 맞춰 Dial `.panel`(16px → 20)보다 둥글게.
    public static let card: CGFloat = 26
    /// 카드 안의 블록 (검토 카드·행 하이라이트, 12px).
    public static let inner: CGFloat = 15
    /// 오목한 트랙 (탭 홈 10px).
    public static let track: CGFloat = 12.5
    /// 트랙 위 선택 칸 (탭 알약 7px).
    public static let control: CGFloat = 9
    /// 막대 차트 막대.
    public static let bar: CGFloat = 3
}

/// 움직임. Dial의 ease-out-strong(0.23, 1, 0.32, 1) — 빨리 출발해 부드럽게 멈춘다.
extension Animation {
    public static let strongOut = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.45)
    /// 값이 차오르는 게이지·차트.
    public static let fill = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.9)
    /// 누름 (`--duration-press`).
    public static let press = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.14)
    /// 숫자 굴림 (`--duration-roll`).
    public static let roll = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.26)
    /// 상태 전환 — 색·배경 (`--ease-soft`).
    public static let soft = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.2)
}

extension View {
    /// 안쪽 반 픽셀 테두리 (`inset-ring-[0.5px] inset-ring-white/12`).
    public func insetRing(
        _ shape: some InsettableShape,
        _ opacity: Double,
        width: CGFloat = 0.5,
    ) -> some View {
        overlay { shape.strokeBorder(Palette.fill(opacity), lineWidth: width) }
    }
}
