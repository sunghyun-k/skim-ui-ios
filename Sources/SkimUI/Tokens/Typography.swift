import SwiftUI

/// 글자 단계. 전부 SF Pro(시스템). 크기는 다이내믹 타입을 따라 커진다. 자간은 Dial처럼 좁게(em 단위 음수).
/// 크기는 Dial 패널 CSS px × 1.25 (패널은 메뉴 막대 크기라 폰에 맞춰 키움): 42 → hero 52, 13 → headline 16, 11 →
/// footnote 13.5.
/// 숫자가 들어가는 단계는 고정폭 숫자 — 값이 바뀌어도 글자가 흔들리지 않게.
public enum TextRole: Sendable {
    /// 카드의 주인공 숫자 (52pt, Dial 큰 타이머 42px)
    case hero
    /// 화면 맨 위 큰 숫자 (64pt, 예약)
    case display
    /// 화면 제목 (34pt) — 시작·권한 화면처럼 내비게이션 바가 없는 곳
    case largeTitle
    /// 화면 안 이름 제목 (26pt) — 회선 상세의 회선 이름
    case pageTitle
    /// 주인공 옆의 단위 ("MB", "일째") — 숫자의 약 0.3배 (Dial 타이머 옆 초)
    case unit
    /// 카드 제목, 보조 큰 숫자 (22pt)
    case title
    /// 행 제목·버튼 (16pt medium, Dial 13px)
    case headline
    /// 본문 (15.5pt, Dial 행 12.5px)
    case body
    /// 보조 문장·값 (14.5pt, Dial 탭 11.5px)
    case callout
    /// 작은 설명·섹션 제목 (13.5pt, Dial 11px)
    case footnote
    /// 칩·축 레이블 (12.5pt, Dial 10px)
    case caption

    var size: CGFloat {
        switch self {
        case .display: 64
        case .hero: 52
        case .largeTitle: 34
        case .pageTitle: 26
        case .unit: 16
        case .title: 22
        case .headline: 16
        case .body: 15.5
        case .callout: 14.5
        case .footnote: 13.5
        case .caption: 12.5
        }
    }

    var weight: Font.Weight {
        switch self {
        case .display, .hero, .largeTitle, .pageTitle: .semibold
        case .unit: .medium
        case .title: .semibold
        case .headline: .medium
        case .body: .regular
        case .callout, .footnote, .caption: .medium
        }
    }

    /// em 단위 자간 (Dial: 큰 타이머 -.035em, 제목 -.02em, 본문 -.01em, 작은 글자 0).
    var tracking: CGFloat {
        switch self {
        case .display, .hero: -0.035
        case .largeTitle, .pageTitle: -0.02
        case .title: -0.02
        case .unit, .headline, .body: -0.01
        case .callout, .footnote: -0.005
        case .caption: 0
        }
    }

    var relativeTo: Font.TextStyle {
        switch self {
        case .display, .hero, .largeTitle: .largeTitle
        case .pageTitle: .title
        case .unit, .title: .title3
        case .headline, .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption
        }
    }
}

private struct TextRoleModifier: ViewModifier {
    let role: TextRole
    @ScaledMetric private var size: CGFloat

    init(role: TextRole) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.size, relativeTo: role.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: role.weight))
            .tracking(size * role.tracking)
            .monospacedDigit()
    }
}

extension View {
    /// 글자 단계 적용: `.textRole(.hero)`
    public func textRole(_ role: TextRole) -> some View {
        modifier(TextRoleModifier(role: role))
    }
}
