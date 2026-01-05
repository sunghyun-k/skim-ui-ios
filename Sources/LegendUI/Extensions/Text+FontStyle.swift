// MARK: - Text+FontStyle

import SwiftUI

#if canImport(UIKit)
    import UIKit

    public typealias PlatformFont = UIFont
#elseif canImport(AppKit)
    import AppKit

    public typealias PlatformFont = NSFont

    extension NSFont {
        var lineHeight: CGFloat {
            ascender - descender + leading
        }
    }
#endif

// MARK: - LineHeight

/// Represents a line height specification for text rendering.
///
/// Line height can be specified either as an exact point value or as a multiple of the font's point
/// size.
public enum LineHeight: Hashable, Sendable {
    /// Specifies an exact line height in points.
    case exact(points: CGFloat)

    /// Specifies a line height as a multiple of the font's point size.
    case multiple(factor: CGFloat)

    /// Resolves the line height to an absolute point value for a given font.
    ///
    /// - Parameter font: The platform font to calculate the line height for.
    /// - Returns: The resolved line height in points.
    public func resolve(for font: PlatformFont) -> CGFloat {
        switch self {
        case .exact(let points):
            points
        case .multiple(let factor):
            font.pointSize * factor
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension LineHeight {
    fileprivate func asSwiftUI() -> AttributedString.LineHeight {
        switch self {
        case .exact(let points):
            .exact(points: points)
        case .multiple(let factor):
            .multiple(factor: factor)
        }
    }
}

// MARK: - FontStyle

/// A container that combines a platform font with a line height specification.
///
/// Use `FontStyle` to define reusable text styles with consistent font and line height settings.
public struct FontStyle: @unchecked Sendable {
    /// The platform-specific font (UIFont on iOS, NSFont on macOS).
    public let font: PlatformFont

    /// The line height specification for this style.
    public let lineHeight: LineHeight

    /// Creates a new font style with the specified font and line height.
    ///
    /// - Parameters:
    ///   - font: The platform font to use.
    ///   - lineHeight: The line height specification.
    public init(
        font: PlatformFont,
        lineHeight: LineHeight,
    ) {
        self.font = font
        self.lineHeight = lineHeight
    }

    /// Converts the platform font to a SwiftUI Font.
    ///
    /// - Note: This property does not apply line height. Use this for views like `TextField`
    ///   that don't support line height adjustments.
    public var swiftUIFont: Font {
        Font(font)
    }

    /// Returns a new font style with the specified font weight.
    ///
    /// - Parameter weight: The font weight to apply.
    /// - Returns: A new `FontStyle` with the same size and line height but different weight.
    public func weight(_ weight: PlatformFont.Weight) -> FontStyle {
        FontStyle(
            font: .systemFont(ofSize: font.pointSize, weight: weight),
            lineHeight: lineHeight,
        )
    }
}

// MARK: - Text Extension

extension Text {
    /// Applies a font style to the text, including both font and line height.
    ///
    /// On iOS 26+/macOS 26+, this uses the native `lineHeight` modifier.
    /// On earlier versions, line height is simulated using `lineSpacing` with vertical padding.
    ///
    /// - Parameter style: The font style to apply.
    /// - Returns: A view with the font style applied.
    @ViewBuilder
    public func fontStyle(_ style: FontStyle) -> some View {
        let resolvedLineHeight = style.lineHeight.resolve(for: style.font)
        let spacing = resolvedLineHeight - style.font.lineHeight
        if #available(iOS 26, macOS 26, *) {
            font(Font(style.font))
                .lineHeight(style.lineHeight.asSwiftUI())
        } else {
            font(Font(style.font))
                .lineSpacing(spacing)
                .padding(.vertical, spacing / 2)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a font style to a view.
    ///
    /// - Parameter style: The font style to apply.
    /// - Returns: A view with the font style applied.
    ///
    /// - Note: On iOS 26+/macOS 26+, both font and line height are applied.
    ///   On earlier versions, only the font is applied; line height is not supported for generic
    /// views.
    ///   For `Text` views, use the `Text.fontStyle(_:)` method which supports line height on all
    /// versions.
    @_disfavoredOverload
    @ViewBuilder
    public func fontStyle(_ style: FontStyle) -> some View {
        if #available(iOS 26, macOS 26, *) {
            font(Font(style.font))
                .lineHeight(style.lineHeight.asSwiftUI())
        } else {
            font(Font(style.font))
        }
    }
}
