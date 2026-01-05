import SwiftUI

// MARK: - SegmentedSelectStyle

/// A segmented control style with a sliding selection indicator.
///
/// Displays options horizontally with an animated indicator that slides to the
/// selected item. Similar to iOS `Picker` with `.segmented` style or tab controls.
///
/// - Important: The `description` property of `SelectItem` is ignored in this style.
public struct SegmentedSelectStyle: SelectStyle {
    private let sizeType: SelectSizeType

    public init(size: SelectSizeType = .md) {
        self.sizeType = size
    }

    public func makeBody(configuration: SelectStyleConfiguration) -> some View {
        SegmentedSelectStyleView(
            configuration: configuration,
            sizeType: sizeType,
        )
    }
}

// MARK: - SegmentedSelectStyleView

private struct SegmentedSelectStyleView: View {
    @Environment(\.legendTheme) private var theme

    let configuration: SelectStyleConfiguration
    let sizeType: SelectSizeType

    private var size: SegmentedSelectSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        SegmentedContainerView(
            items: configuration.items,
            size: size,
            isInvalid: configuration.isInvalid,
            isDisabled: configuration.isDisabled,
            theme: theme,
        )
    }
}

// MARK: - SegmentedSelectSize

private struct SegmentedSelectSize {
    let padding: EdgeInsets
    let itemPadding: EdgeInsets
    let fontStyle: FontStyle
    let cornerRadius: CGFloat

    static func resolved(
        _ type: SelectSizeType,
        layout: LegendLayout,
        typography: LegendTypography,
    ) -> SegmentedSelectSize {
        switch type {
        case .sm:
            SegmentedSelectSize(
                padding: EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3),
                itemPadding: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
                fontStyle: typography.sm,
                cornerRadius: layout.radius.medium,
            )
        case .md:
            SegmentedSelectSize(
                padding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
                itemPadding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
                fontStyle: typography.base,
                cornerRadius: layout.radius.medium,
            )
        case .lg:
            SegmentedSelectSize(
                padding: EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5),
                itemPadding: EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20),
                fontStyle: typography.base,
                cornerRadius: layout.radius.large,
            )
        }
    }
}

// MARK: - Segment Frame Preference

private struct SegmentFramePreferenceKey: PreferenceKey {
    static let defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - SegmentedContainerView

private struct SegmentedContainerView: View {
    let items: [SelectStyleConfiguration.Item]
    let size: SegmentedSelectSize
    let isInvalid: Bool
    let isDisabled: Bool
    let theme: LegendTheme

    @State private var segmentFrames: [Int: CGRect] = [:]
    @State private var isDragging = false
    @State private var dragTargetIndex: Int?

    private var selectedIndex: Int? {
        items.firstIndex { $0.isSelected }
    }

    private var currentIndicatorIndex: Int? {
        if isDragging, let dragIndex = dragTargetIndex {
            return dragIndex
        }
        return selectedIndex
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                SegmentedItemView(
                    item: item,
                    size: size,
                    isInvalid: isInvalid,
                    theme: theme,
                    showIndicator: false,
                )
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: SegmentFramePreferenceKey.self,
                                value: [index: geo.frame(in: .named("segmentedContainer"))],
                            )
                    }
                }
            }
        }
        .background(alignment: .leading) {
            if let indicatorIndex = currentIndicatorIndex,
               let frame = segmentFrames[indicatorIndex]
            {
                RoundedRectangle(
                    cornerRadius: size.cornerRadius - 2,
                    style: .continuous,
                )
                .fill(theme.colors.surface.primary)
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                .frame(width: frame.width, height: frame.height)
                .scaleEffect(isDragging ? 0.95 : 1.0)
                .offset(x: frame.minX, y: frame.minY)
                .animation(
                    isDragging ? .interactiveSpring() : .spring(duration: 0.3, bounce: 0.15),
                    value: indicatorIndex,
                )
                .animation(.spring(duration: 0.2), value: isDragging)
            }
        }
        .coordinateSpace(name: "segmentedContainer")
        .onPreferenceChange(SegmentFramePreferenceKey.self) { frames in
            segmentFrames = frames
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !isDisabled else { return }
                    isDragging = true
                    dragTargetIndex = indexForLocation(value.location)
                }
                .onEnded { value in
                    guard !isDisabled else { return }
                    if let targetIndex = indexForLocation(value.location),
                       !items[targetIndex].isDisabled
                    {
                        items[targetIndex].select()
                    }
                    withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                        isDragging = false
                        dragTargetIndex = nil
                    }
                },
        )
        .padding(size.padding)
        .background(theme.colors.surface.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
        .opacity(isDisabled ? theme.layout.opacity.disabled : 1)
    }

    private func indexForLocation(_ location: CGPoint) -> Int? {
        for (index, frame) in segmentFrames {
            if location.x >= frame.minX, location.x <= frame.maxX {
                return index
            }
        }
        // If outside bounds, return closest edge
        if location.x < 0 {
            return 0
        }
        if !segmentFrames.isEmpty {
            return segmentFrames.count - 1
        }
        return nil
    }
}

// MARK: - SegmentedItemView

private struct SegmentedItemView: View {
    let item: SelectStyleConfiguration.Item
    let size: SegmentedSelectSize
    let isInvalid: Bool
    let theme: LegendTheme
    let showIndicator: Bool

    @State private var isHovered = false

    var body: some View {
        item.label
            .fontStyle(size.fontStyle)
            .fontWeight(item.isSelected ? .medium : .regular)
            .foregroundStyle(labelColor)
            .padding(size.itemPadding)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovered = hovering
            }
            .opacity(item.isDisabled ? theme.layout.opacity.disabled : 1)
            .animation(.spring(duration: 0.3, bounce: 0.15), value: item.isSelected)
    }

    // MARK: - Colors

    private var labelColor: Color {
        if item.isDisabled {
            return theme.colors.disabled.foreground
        }
        if item.isSelected {
            return theme.colors.foreground.primary
        }
        return theme.colors.foreground.secondary
    }
}

// MARK: - Style Extension

extension SelectStyle where Self == SegmentedSelectStyle {
    /// The default segmented style with medium size.
    public static var segmented: SegmentedSelectStyle {
        SegmentedSelectStyle()
    }

    /// Creates a segmented style with the specified size.
    ///
    /// - Parameter size: The size preset for the segmented control.
    public static func segmented(size: SelectSizeType) -> SegmentedSelectStyle {
        SegmentedSelectStyle(size: size)
    }
}

// MARK: - Preview

#if DEBUG
    private enum Tab: String, CaseIterable {
        case photos = "Photos"
        case music = "Music"
        case videos = "Videos"
    }

    #Preview("Segmented Style") {
        struct PreviewContainer: View {
            @State private var selected: Tab = .photos

            var body: some View {
                VStack(spacing: 32) {
                    Text("Selected: \(selected.rawValue)")
                        .font(.headline)

                    Select(
                        selection: $selected,
                        items: [
                            SelectItem("Photos", value: .photos),
                            SelectItem("Music", value: .music),
                            SelectItem("Videos", value: .videos),
                        ],
                        style: .segmented,
                    )
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Segmented Sizes") {
        struct PreviewContainer: View {
            @State private var sm: Tab = .photos
            @State private var md: Tab = .music
            @State private var lg: Tab = .videos

            var items: [SelectItem<Tab>] {
                [
                    SelectItem("Photos", value: .photos),
                    SelectItem("Music", value: .music),
                    SelectItem("Videos", value: .videos),
                ]
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Small")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Select(
                            selection: $sm,
                            items: items,
                            style: .segmented(size: .sm),
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medium (Default)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Select(
                            selection: $md,
                            items: items,
                            style: .segmented(size: .md),
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Large")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Select(
                            selection: $lg,
                            items: items,
                            style: .segmented(size: .lg),
                        )
                    }
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Segmented with Disabled") {
        struct PreviewContainer: View {
            @State private var selected: Tab = .photos

            var body: some View {
                VStack(spacing: 24) {
                    Text("Selected: \(selected.rawValue)")
                        .font(.headline)

                    Select(
                        selection: $selected,
                        items: [
                            SelectItem("Photos", value: .photos),
                            SelectItem("Music", value: .music, isDisabled: true),
                            SelectItem("Videos", value: .videos),
                        ],
                        style: .segmented,
                    )

                    Text("Entire component disabled:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Select(
                        selection: $selected,
                        items: [
                            SelectItem("Photos", value: .photos),
                            SelectItem("Music", value: .music),
                            SelectItem("Videos", value: .videos),
                        ],
                        style: .segmented,
                    )
                    .disabled(true)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }
#endif
