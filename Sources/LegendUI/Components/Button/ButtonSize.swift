import SwiftUI

// MARK: - ButtonSize

// MARK: - ButtonSizeType

/// Predefined button size variants.
public enum ButtonSizeType: String, Sendable, CaseIterable {
    case sm
    case md
    case lg
}

// MARK: - ButtonSize

/// A configuration that defines the layout dimensions for a button.
///
/// Use this struct to create custom button sizes with specific padding, spacing,
/// and corner radius values. For standard sizes, use `ButtonSizeType` instead.
public struct ButtonSize: Sendable {
    /// Vertical padding applied to the button content.
    public let verticalPadding: CGFloat

    /// Horizontal padding applied to the button content.
    public let horizontalPadding: CGFloat

    /// Padding applied when the button is in icon-only mode.
    public let iconOnlyPadding: CGFloat

    /// Spacing between elements inside the button (e.g., icon and text).
    public let spacing: CGFloat

    /// Corner radius for the button's rounded rectangle background.
    public let cornerRadius: CGFloat

    /// Font style applied to the button's text content.
    public let fontStyle: FontStyle

    /// Creates a new button size configuration.
    ///
    /// - Parameters:
    ///   - verticalPadding: Vertical padding for the button content.
    ///   - horizontalPadding: Horizontal padding for the button content.
    ///   - iconOnlyPadding: Padding used when the button displays only an icon.
    ///   - spacing: Spacing between icon and text elements.
    ///   - cornerRadius: Corner radius for the button background.
    ///   - fontStyle: Typography style for the button text.
    public init(
        verticalPadding: CGFloat,
        horizontalPadding: CGFloat,
        iconOnlyPadding: CGFloat,
        spacing: CGFloat,
        cornerRadius: CGFloat,
        fontStyle: FontStyle,
    ) {
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.iconOnlyPadding = iconOnlyPadding
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.fontStyle = fontStyle
    }

    // MARK: - Layout-based Factory

    /// Resolves a button size type to concrete dimensions using the provided theme settings.
    ///
    /// - Parameters:
    ///   - type: The predefined size type to resolve.
    ///   - layout: The layout configuration providing spacing and radius values.
    ///   - typography: The typography configuration providing font styles.
    /// - Returns: A `ButtonSize` instance with resolved dimension values.
    public static func resolved(
        _ type: ButtonSizeType,
        layout: LegendLayout,
        typography: LegendTypography,
    ) -> ButtonSize {
        switch type {
        case .sm:
            ButtonSize(
                verticalPadding: layout.spacing.small,
                horizontalPadding: layout.spacing.small + layout.spacing.xSmall,
                iconOnlyPadding: layout.spacing.small,
                spacing: layout.spacing.small - 2,
                cornerRadius: layout.radius.small,
                fontStyle: typography.sm.weight(.medium),
            )
        case .md:
            ButtonSize(
                verticalPadding: layout.spacing.small + layout.spacing.xSmall,
                horizontalPadding: layout.spacing.medium,
                iconOnlyPadding: layout.spacing.small + layout.spacing.xSmall,
                spacing: layout.spacing.small,
                cornerRadius: layout.radius.medium - 2,
                fontStyle: typography.base.weight(.medium),
            )
        case .lg:
            ButtonSize(
                verticalPadding: layout.spacing.medium,
                horizontalPadding: layout.spacing.large,
                iconOnlyPadding: layout.spacing.medium,
                spacing: layout.spacing.small + 2,
                cornerRadius: layout.radius.medium,
                fontStyle: typography.lg,
            )
        }
    }
}
