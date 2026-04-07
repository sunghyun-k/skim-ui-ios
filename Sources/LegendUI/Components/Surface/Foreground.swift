import SwiftUI

// MARK: - ShapeStyle Extensions (Foreground)

extension ShapeStyle where Self == Color {
    /// The primary foreground color for text and icons.
    public static var foregroundPrimary: Color { SharedTheme.value.colors.foreground.primary }

    /// The secondary foreground color for supporting text and icons.
    public static var foregroundSecondary: Color { SharedTheme.value.colors.foreground.secondary }

    /// The muted foreground color for de-emphasized text and icons.
    public static var foregroundMuted: Color { SharedTheme.value.colors.foreground.muted }
}
