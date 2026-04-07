import SwiftUI

// MARK: - Surface

// MARK: - Surface ShapeStyles

/// Primary surface background style.
///
/// Use this for main content containers and cards.
/// Automatically adapts to the current theme's primary surface color.
public struct SurfaceStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.surface.primary
    }
}

/// Foreground color style for text and icons on surfaces.
///
/// Use this to ensure readable contrast on any surface variant.
public struct SurfaceForegroundStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.surface.foreground
    }
}

/// Secondary surface background style.
///
/// Use this for nested containers or less prominent backgrounds.
public struct SurfaceSecondaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.surface.secondary
    }
}

/// Tertiary surface background style.
///
/// Use this for subtle backgrounds or hover states.
public struct SurfaceTertiaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.surface.tertiary
    }
}

/// Quaternary surface background style.
///
/// Use this for the most subtle backgrounds or dividers.
public struct SurfaceQuaternaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.surface.quaternary
    }
}

// MARK: - ShapeStyle Extensions

extension ShapeStyle where Self == SurfaceStyle {
    /// The primary surface background style.
    public static var surface: SurfaceStyle { SurfaceStyle() }
}

extension ShapeStyle where Self == SurfaceForegroundStyle {
    /// The foreground style for content on surfaces.
    public static var surfaceForeground: SurfaceForegroundStyle { SurfaceForegroundStyle() }
}

extension ShapeStyle where Self == SurfaceSecondaryStyle {
    /// The secondary surface background style.
    public static var surfaceSecondary: SurfaceSecondaryStyle { SurfaceSecondaryStyle() }
}

extension ShapeStyle where Self == SurfaceTertiaryStyle {
    /// The tertiary surface background style.
    public static var surfaceTertiary: SurfaceTertiaryStyle { SurfaceTertiaryStyle() }
}

extension ShapeStyle where Self == SurfaceQuaternaryStyle {
    /// The quaternary surface background style.
    public static var surfaceQuaternary: SurfaceQuaternaryStyle { SurfaceQuaternaryStyle() }
}

// MARK: - Surface Style ViewModifier

/// A view modifier that applies surface styling with background, padding, and rounded corners.
///
/// This modifier provides a convenient way to wrap content in a themed surface container.
/// It automatically applies the appropriate foreground color for readable text.
public struct SurfaceModifier: ViewModifier {
    /// The visual variant of the surface background.
    public enum Variant: String, Sendable, CaseIterable {
        /// Primary surface background (default).
        case `default`
        /// Secondary surface for nested containers.
        case secondary
        /// Tertiary surface for subtle backgrounds.
        case tertiary
        /// Quaternary surface for the most subtle backgrounds.
        case quaternary
        /// Transparent background with no fill.
        case transparent
    }

    private var theme: LegendTheme { SharedTheme.value }

    let variant: Variant
    let padding: CGFloat?
    let cornerRadius: CGFloat?

    /// Creates a surface modifier with the specified styling options.
    ///
    /// - Parameters:
    ///   - variant: The background variant to apply. Defaults to `.default`.
    ///   - padding: Custom padding value. Uses theme's medium spacing if `nil`.
    ///   - cornerRadius: Custom corner radius. Uses theme's xLarge radius if `nil`.
    public init(
        variant: Variant = .default,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
    ) {
        self.variant = variant
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    private var resolvedPadding: CGFloat {
        padding ?? theme.layout.spacing.medium
    }

    private var resolvedCornerRadius: CGFloat {
        cornerRadius ?? theme.layout.radius.xLarge
    }

    public func body(content: Content) -> some View {
        content
            .padding(resolvedPadding)
            .foregroundStyle(theme.colors.surface.foreground)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
    }

    private var backgroundColor: Color {
        switch variant {
        case .default:
            theme.colors.surface.primary
        case .secondary:
            theme.colors.surface.secondary
        case .tertiary:
            theme.colors.surface.tertiary
        case .quaternary:
            theme.colors.surface.quaternary
        case .transparent:
            .clear
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a surface style to the view with background, padding, and rounded corners.
    ///
    /// This modifier wraps the view in a themed surface container that includes:
    /// - A background color based on the selected variant
    /// - Appropriate foreground color for readable text
    /// - Configurable padding and corner radius
    ///
    /// - Parameters:
    ///   - variant: The background variant to apply. Defaults to `.default`.
    ///   - padding: Custom padding value. Uses theme's medium spacing if `nil`.
    ///   - cornerRadius: Custom corner radius. Uses theme's xLarge radius if `nil`.
    /// - Returns: A view with the surface styling applied.
    public func surfaceStyle(
        _ variant: SurfaceModifier.Variant = .default,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
    ) -> some View {
        modifier(SurfaceModifier(
            variant: variant,
            padding: padding,
            cornerRadius: cornerRadius,
        ))
    }
}

// MARK: - Background ShapeStyles

/// Primary background style for page-level backgrounds.
public struct BackgroundPrimaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.background.primary
    }
}

/// Secondary background style.
public struct BackgroundSecondaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.background.secondary
    }
}

extension ShapeStyle where Self == BackgroundPrimaryStyle {
    /// The primary background style for page-level backgrounds.
    public static var legendBackground: BackgroundPrimaryStyle { BackgroundPrimaryStyle() }
}

extension ShapeStyle where Self == BackgroundSecondaryStyle {
    /// The secondary background style.
    public static var legendBackgroundSecondary: BackgroundSecondaryStyle {
        BackgroundSecondaryStyle()
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Surface Colors") {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.surface)
                .frame(height: 60)
                .overlay { Text("surface").foregroundStyle(.surfaceForeground) }

            RoundedRectangle(cornerRadius: 16)
                .fill(.surfaceSecondary)
                .frame(height: 60)
                .overlay { Text("surfaceSecondary").foregroundStyle(.surfaceForeground) }

            RoundedRectangle(cornerRadius: 16)
                .fill(.surfaceTertiary)
                .frame(height: 60)
                .overlay { Text("surfaceTertiary").foregroundStyle(.surfaceForeground) }

            RoundedRectangle(cornerRadius: 16)
                .fill(.surfaceQuaternary)
                .frame(height: 60)
                .overlay { Text("surfaceQuaternary").foregroundStyle(.surfaceForeground) }
        }
        .padding()
        .background(Color("background", bundle: .module))
    }

    #Preview("Surface Style Modifier (Light)") {
        VStack(spacing: 16) {
            Text("Default Surface")
                .surfaceStyle()

            Text("Secondary Surface")
                .surfaceStyle(.secondary)

            Text("Tertiary Surface")
                .surfaceStyle(.tertiary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title").font(.headline)
                Text("Custom padding and corner radius")
            }
            .surfaceStyle(.default, padding: 24, cornerRadius: 16)
        }
        .padding()
        .background(Color("background", bundle: .module))
        .preferredColorScheme(.light)
    }

    #Preview("Surface Style Modifier (Dark)") {
        VStack(spacing: 16) {
            Text("Default Surface")
                .surfaceStyle()

            Text("Secondary Surface")
                .surfaceStyle(.secondary)

            Text("Tertiary Surface")
                .surfaceStyle(.tertiary)
        }
        .padding()
        .background(Color("background", bundle: .module))
        .preferredColorScheme(.dark)
    }
#endif
