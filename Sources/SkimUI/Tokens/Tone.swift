import SwiftUI

/// 상태 톤. **여유는 색을 쓰지 않는다** — 조용할 때는 무채색, 색은 주의·경고에만.
public enum Tone: Int, Comparable, Sendable, CaseIterable {
    /// 값이 없거나 해당 없음.
    case neutral
    /// 여유.
    case calm
    /// 주의.
    case caution
    /// 경고.
    case alert

    public static func < (lhs: Tone, rhs: Tone) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// 글자·칩에 쓰는 색.
    public var color: Color {
        switch self {
        case .neutral: Palette.ink3
        case .calm: Palette.ink2
        case .caution: Palette.cautionInk
        case .alert: Palette.red
        }
    }

    /// 색이 있는 톤인지 (칩 테두리·배너 바탕을 칠할지).
    public var isColored: Bool {
        self == .caution || self == .alert
    }

    /// 게이지·막대 채움 색: 여유는 테마색 → 주의 노랑 → 경고 빨강.
    public var fillColor: Color {
        switch self {
        case .neutral, .calm: Palette.theme
        case .caution: Palette.yellow
        case .alert: Palette.red
        }
    }
}
