import SwiftUI

// MARK: - RadioSelectStyle

// MARK: - RadioIndicatorPlacement

/// The placement of the radio indicator relative to the label.
public enum RadioIndicatorPlacement: Sendable {
    /// Place the indicator on the leading (left) side of the label.
    case leading
    /// Place the indicator on the trailing (right) side of the label.
    case trailing
}

// MARK: - RadioSelectStyle

/// A traditional radio button selection style with configurable indicator placement.
///
/// Displays items in a vertical or horizontal list with circular indicators
/// that fill when selected. This is the default style for Select.
public struct RadioSelectStyle: SelectStyle {
    private let sizeType: SelectSizeType
    private let indicatorPlacement: RadioIndicatorPlacement

    public init(
        size: SelectSizeType = .md,
        indicatorPlacement: RadioIndicatorPlacement = .trailing,
    ) {
        self.sizeType = size
        self.indicatorPlacement = indicatorPlacement
    }

    public func makeBody(configuration: SelectStyleConfiguration) -> some View {
        RadioSelectStyleView(
            configuration: configuration,
            sizeType: sizeType,
            indicatorPlacement: indicatorPlacement,
        )
    }
}

// MARK: - RadioSelectStyleView

private struct RadioSelectStyleView: View {
    @Environment(\.legendTheme) private var theme

    let configuration: SelectStyleConfiguration
    let sizeType: SelectSizeType
    let indicatorPlacement: RadioIndicatorPlacement

    private var size: SelectSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        let layout = configuration.axis == .vertical
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: size.itemSpacing))
            : AnyLayout(HStackLayout(spacing: size.itemSpacing))

        layout {
            ForEach(configuration.items) { item in
                RadioItemView(
                    item: item,
                    size: size,
                    isInvalid: configuration.isInvalid,
                    indicatorPlacement: indicatorPlacement,
                    theme: theme,
                )
            }
        }
        .opacity(configuration.isDisabled ? theme.layout.opacity.disabled : 1)
    }
}

// MARK: - RadioItemView

private struct RadioItemView: View {
    let item: SelectStyleConfiguration.Item
    let size: SelectSize
    let isInvalid: Bool
    let indicatorPlacement: RadioIndicatorPlacement
    let theme: LegendTheme

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button {
            item.select()
        } label: {
            HStack(spacing: size.spacing) {
                if indicatorPlacement == .leading {
                    indicator
                }

                labelContent

                if indicatorPlacement == .trailing {
                    Spacer()
                    indicator
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false },
        )
        .opacity(item.isDisabled ? theme.layout.opacity.disabled : 1)
    }

    private var indicator: some View {
        SelectIndicatorView(
            isSelected: item.isSelected,
            isInvalid: isInvalid,
            isHovered: isHovered,
            isPressed: isPressed,
            size: size,
            theme: theme,
        )
    }

    private var labelContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            item.label
                .fontStyle(size.labelFontStyle)
                .foregroundStyle(labelColor)

            if let description = item.description {
                description
                    .fontStyle(size.descriptionFontStyle)
                    .foregroundStyle(theme.colors.foreground.muted)
            }
        }
    }

    private var labelColor: Color {
        if item.isDisabled {
            return theme.colors.disabled.foreground
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - Style Extension

extension SelectStyle where Self == RadioSelectStyle {
    /// The default radio style with trailing indicator and medium size.
    public static var radio: RadioSelectStyle {
        RadioSelectStyle()
    }

    /// Creates a radio style with custom configuration.
    ///
    /// - Parameters:
    ///   - size: The size preset for the radio items. Defaults to `.md`.
    ///   - indicatorPlacement: Position of the indicator (`.leading` or `.trailing`). Defaults to
    /// `.trailing`.
    public static func radio(
        size: SelectSizeType = .md,
        indicatorPlacement: RadioIndicatorPlacement = .trailing,
    ) -> RadioSelectStyle {
        RadioSelectStyle(size: size, indicatorPlacement: indicatorPlacement)
    }

    /// A radio style with the indicator on the leading (left) side.
    public static var leadingIndicator: RadioSelectStyle {
        RadioSelectStyle(indicatorPlacement: .leading)
    }

    /// Creates a leading indicator radio style with the specified size.
    ///
    /// - Parameter size: The size preset for the radio items.
    public static func leadingIndicator(size: SelectSizeType) -> RadioSelectStyle {
        RadioSelectStyle(size: size, indicatorPlacement: .leading)
    }
}

// MARK: - Preview

#if DEBUG
    private enum Fruit: String, CaseIterable {
        case apple = "Apple"
        case banana = "Banana"
        case orange = "Orange"
        case grape = "Grape"
    }

    #Preview("Radio Style") {
        struct PreviewContainer: View {
            @State private var trailing: Fruit = .apple
            @State private var leading: Fruit = .banana

            var items: [SelectItem<Fruit>] {
                [
                    SelectItem("Apple", description: "Sweet and crunchy", value: .apple),
                    SelectItem("Banana", description: "Rich in potassium", value: .banana),
                    SelectItem("Orange", description: "High in vitamin C", value: .orange),
                ]
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trailing Indicator (Default)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Select(selection: $trailing, items: items)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Leading Indicator")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Select(
                            selection: $leading,
                            items: items,
                            style: .leadingIndicator,
                        )
                    }
                }
                .padding()
            }
        }

        return PreviewContainer()
    }
#endif
