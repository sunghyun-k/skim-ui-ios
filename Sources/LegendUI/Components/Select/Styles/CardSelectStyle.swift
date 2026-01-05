import SwiftUI

// MARK: - CardSelectStyle

/// A card-based selection style with elevated appearance.
///
/// Displays items as cards with leading radio indicators. Selected cards show
/// an accent-colored border and subtle background tint.
public struct CardSelectStyle: SelectStyle {
    private let sizeType: SelectSizeType

    public init(size: SelectSizeType = .md) {
        self.sizeType = size
    }

    public func makeBody(configuration: SelectStyleConfiguration) -> some View {
        CardSelectStyleView(
            configuration: configuration,
            sizeType: sizeType,
        )
    }
}

// MARK: - CardSelectStyleView

private struct CardSelectStyleView: View {
    @Environment(\.legendTheme) private var theme

    let configuration: SelectStyleConfiguration
    let sizeType: SelectSizeType

    private var size: SelectSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        VStack(spacing: size.itemSpacing) {
            ForEach(configuration.items) { item in
                CardItemView(
                    item: item,
                    size: size,
                    isInvalid: configuration.isInvalid,
                    theme: theme,
                )
            }
        }
        .opacity(configuration.isDisabled ? theme.layout.opacity.disabled : 1)
    }
}

// MARK: - CardItemView

private struct CardItemView: View {
    let item: SelectStyleConfiguration.Item
    let size: SelectSize
    let isInvalid: Bool
    let theme: LegendTheme

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button {
            item.select()
        } label: {
            HStack(spacing: size.spacing) {
                SelectIndicatorView(
                    isSelected: item.isSelected,
                    isInvalid: isInvalid,
                    isHovered: isHovered,
                    isPressed: isPressed,
                    size: size,
                    theme: theme,
                )

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

                Spacer()
            }
            .padding(.horizontal, theme.layout.spacing.medium)
            .padding(.vertical, theme.layout.spacing.small + 4)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(
                cornerRadius: theme.layout.radius.medium,
                style: .continuous,
            ))
            .overlay {
                RoundedRectangle(cornerRadius: theme.layout.radius.medium, style: .continuous)
                    .stroke(borderColor, lineWidth: item.isSelected ? 2 : 1.5)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: item.isSelected)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if item.isSelected {
            return theme.colors.accent.default.opacity(0.1)
        }
        if isHovered {
            return theme.colors.surface.secondary
        }
        return theme.colors.surface.primary
    }

    private var borderColor: Color {
        if isInvalid {
            return theme.colors.danger.default
        }
        if item.isSelected {
            return theme.colors.accent.default
        }
        if isHovered {
            return theme.colors.foreground.muted.opacity(0.3)
        }
        return theme.colors.border
    }

    private var labelColor: Color {
        if item.isDisabled {
            return theme.colors.disabled.foreground
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - Style Extension

extension SelectStyle where Self == CardSelectStyle {
    /// The default card style with medium size.
    public static var card: CardSelectStyle {
        CardSelectStyle()
    }

    /// Creates a card style with the specified size.
    ///
    /// - Parameter size: The size preset for the card items.
    public static func card(size: SelectSizeType) -> CardSelectStyle {
        CardSelectStyle(size: size)
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

    #Preview("Card Style") {
        struct PreviewContainer: View {
            @State private var selected: Fruit = .apple

            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select a Fruit")
                        .font(.headline)

                    Select(
                        selection: $selected,
                        items: [
                            SelectItem(
                                "Apple",
                                description: "Sweet and crunchy",
                                value: .apple,
                            ),
                            SelectItem(
                                "Banana",
                                description: "Rich in potassium",
                                value: .banana,
                            ),
                            SelectItem(
                                "Orange",
                                description: "High in vitamin C",
                                value: .orange,
                            ),
                        ],
                        style: .card,
                    )
                }
                .padding()
            }
        }

        return PreviewContainer()
    }
#endif
