import SwiftUI

// MARK: - LegendTheme

/// The root theme configuration containing colors, layout, and typography settings.
///
/// Use this struct to customize the appearance of all LegendUI components.
/// Access the current theme via `SharedTheme.value`.
public struct LegendTheme: Sendable {
    /// The color palette for the theme.
    public let colors: LegendColors

    /// The layout constants (spacing, radius, border width) for the theme.
    public let layout: LegendLayout

    /// The typography styles for the theme.
    public let typography: LegendTypography

    /// Creates a new theme with the specified colors, layout, and typography.
    ///
    /// - Parameters:
    ///   - colors: The color palette configuration.
    ///   - layout: The layout constants configuration.
    ///   - typography: The typography styles configuration.
    public init(
        colors: LegendColors,
        layout: LegendLayout,
        typography: LegendTypography,
    ) {
        self.colors = colors
        self.layout = layout
        self.typography = typography
    }
}

// MARK: - Default Theme

extension LegendTheme {
    /// The default theme with standard colors, layout, and typography.
    ///
    /// This theme uses dynamic colors from the asset catalog that automatically
    /// adapt to light and dark modes.
    public static let `default` = LegendTheme(
        colors: .default,
        layout: .default,
        typography: .default,
    )
}
