import SwiftUI

// MARK: - Foreground ShapeStyles

/// Primary foreground style for text and icons.
///
/// Use this for main content text. Automatically adapts to the current theme.
public struct ForegroundPrimaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.foreground.primary
    }
}

/// Secondary foreground style for supporting text and icons.
///
/// Use this for less prominent content like subtitles or descriptions.
public struct ForegroundSecondaryStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.foreground.secondary
    }
}

/// Muted foreground style for de-emphasized text and icons.
///
/// Use this for the least prominent content like placeholders or hints.
public struct ForegroundMutedStyle: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> some ShapeStyle {
        SharedTheme.value.colors.foreground.muted
    }
}

// MARK: - ShapeStyle Extensions

extension ShapeStyle where Self == ForegroundPrimaryStyle {
    /// The primary foreground style for text and icons.
    public static var foregroundPrimary: ForegroundPrimaryStyle { ForegroundPrimaryStyle() }
}

extension ShapeStyle where Self == ForegroundSecondaryStyle {
    /// The secondary foreground style for supporting text and icons.
    public static var foregroundSecondary: ForegroundSecondaryStyle { ForegroundSecondaryStyle() }
}

extension ShapeStyle where Self == ForegroundMutedStyle {
    /// The muted foreground style for de-emphasized text and icons.
    public static var foregroundMuted: ForegroundMutedStyle { ForegroundMutedStyle() }
}
