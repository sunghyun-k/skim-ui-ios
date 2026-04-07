import SwiftUI

// MARK: - Separator

// MARK: - Separator Variant

/// The visual thickness style of a separator.
public enum SeparatorVariant: Sendable {
    /// A hairline separator (0.5pt). Suitable for subtle content division.
    case thin
    /// A bold separator (6pt). Suitable for major section breaks.
    case thick

    var thickness: CGFloat {
        switch self {
        case .thin:
            0.5
        case .thick:
            6
        }
    }
}

// MARK: - Separator Orientation

/// The direction in which a separator extends.
public enum SeparatorOrientation: Sendable {
    /// A horizontal line that spans the width of its container.
    case horizontal
    /// A vertical line that spans the height of its container.
    case vertical
}

// MARK: - Separator View

/// A visual divider that separates content in layouts.
///
/// Use `Separator` to create visual boundaries between content sections.
/// It adapts to the current theme's divider color by default.
public struct Separator: View {
    private var theme: LegendTheme { SharedTheme.value }

    private let variant: SeparatorVariant
    private let orientation: SeparatorOrientation
    private let thickness: CGFloat?
    private let color: Color?

    /// Creates a separator with the specified configuration.
    ///
    /// - Parameters:
    ///   - variant: The thickness style. Defaults to `.thin`.
    ///   - orientation: The direction of the separator. Defaults to `.horizontal`.
    ///   - thickness: A custom thickness value that overrides the variant's default.
    ///   - color: A custom color that overrides the theme's divider color.
    public init(
        variant: SeparatorVariant = .thin,
        orientation: SeparatorOrientation = .horizontal,
        thickness: CGFloat? = nil,
        color: Color? = nil,
    ) {
        self.variant = variant
        self.orientation = orientation
        self.thickness = thickness
        self.color = color
    }

    private var resolvedThickness: CGFloat {
        thickness ?? variant.thickness
    }

    private var resolvedColor: Color {
        color ?? theme.colors.divider
    }

    public var body: some View {
        switch orientation {
        case .horizontal:
            Rectangle()
                .fill(resolvedColor)
                .frame(height: resolvedThickness)
                .frame(maxWidth: .infinity)
        case .vertical:
            Rectangle()
                .fill(resolvedColor)
                .frame(width: resolvedThickness)
                .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Variants") {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Thin (default)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(variant: .thin)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Thick")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(variant: .thick)
            }
        }
        .padding()
    }

    #Preview("Orientation") {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Horizontal (default)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Vertical")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Spacer()
                    Separator(orientation: .vertical)
                        .frame(height: 80)
                    Spacer()
                }
            }
        }
        .padding()
    }

    #Preview("Custom Thickness") {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Default (hairline)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("1px")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("2px")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("5px")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 5)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("10px")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 10)
            }
        }
        .padding()
    }

    #Preview("Custom Colors") {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Accent Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 2, color: .blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Success Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 2, color: .green)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Warning Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 2, color: .orange)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Danger Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Separator(thickness: 2, color: .red)
            }
        }
        .padding()
    }

    #Preview("In Action") {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("LegendUI")
                    .font(.headline)
                Text("A modern SwiftUI component library.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Separator()
                .padding(.horizontal)

            HStack(spacing: 0) {
                Text("Components")
                    .font(.subheadline)
                Separator(orientation: .vertical)
                    .frame(height: 20)
                    .padding(.horizontal, 12)
                Text("Themes")
                    .font(.subheadline)
                Separator(orientation: .vertical)
                    .frame(height: 20)
                    .padding(.horizontal, 12)
                Text("Examples")
                    .font(.subheadline)
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
#endif
