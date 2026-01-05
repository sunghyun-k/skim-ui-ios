import SwiftUI

// MARK: - DropdownSelectStyle

// MARK: - Placement Types

/// The vertical placement of the dropdown menu relative to the trigger.
public enum SelectVerticalPlacement: Sendable {
    /// Display the menu below the trigger.
    case bottom
    /// Display the menu above the trigger.
    case top
    /// Automatically determine placement based on available screen space.
    case auto
}

/// The horizontal alignment of the dropdown menu relative to the trigger.
public enum SelectHorizontalAlignment: Sendable {
    /// Align the menu to the leading edge of the trigger.
    case leading
    /// Align the menu to the trailing edge of the trigger.
    case trailing
}

// MARK: - DropdownSelectStyle

/// A dropdown-based selection style that shows options in a floating menu.
///
/// Displays a trigger button showing the current selection (or placeholder).
/// Tapping reveals a menu with all options. Supports configurable placement and alignment.
///
/// - Note: This style does not work properly on macOS due to window overlay limitations.
///   For macOS, consider using ``PickerSelectStyle`` instead.
public struct DropdownSelectStyle: SelectStyle {
    private let sizeType: SelectSizeType
    private let placeholder: String
    private let label: String?
    private let verticalPlacement: SelectVerticalPlacement
    private let horizontalAlignment: SelectHorizontalAlignment

    public init(
        size: SelectSizeType = .md,
        placeholder: String,
        label: String? = nil,
        placement: SelectVerticalPlacement = .auto,
        alignment: SelectHorizontalAlignment = .leading,
    ) {
        self.sizeType = size
        self.placeholder = placeholder
        self.label = label
        self.verticalPlacement = placement
        self.horizontalAlignment = alignment
    }

    public func makeBody(configuration: SelectStyleConfiguration) -> some View {
        DropdownSelectStyleView(
            configuration: configuration,
            sizeType: sizeType,
            placeholder: placeholder,
            label: label,
            verticalPlacement: verticalPlacement,
            horizontalAlignment: horizontalAlignment,
        )
    }
}

// MARK: - DropdownSelectStyleView

private struct DropdownSelectStyleView: View {
    @Environment(\.legendTheme) private var theme

    let configuration: SelectStyleConfiguration
    let sizeType: SelectSizeType
    let placeholder: String
    let label: String?
    let verticalPlacement: SelectVerticalPlacement
    let horizontalAlignment: SelectHorizontalAlignment

    private var size: SelectSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        DropdownSelectView(
            configuration: configuration,
            size: size,
            sizeType: sizeType,
            placeholder: placeholder,
            label: label,
            verticalPlacement: verticalPlacement,
            horizontalAlignment: horizontalAlignment,
            theme: theme,
        )
    }
}

// MARK: - DropdownSelectView

private struct DropdownSelectView: View {
    let configuration: SelectStyleConfiguration
    let size: SelectSize
    let sizeType: SelectSizeType
    let placeholder: String
    let label: String?
    let verticalPlacement: SelectVerticalPlacement
    let horizontalAlignment: SelectHorizontalAlignment
    let theme: LegendTheme

    @State private var isPresented = false
    @State private var triggerGlobalFrame: CGRect = .zero

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack {
                if let selectedItem = configuration.selectedItem {
                    selectedItem.label
                        .fontStyle(size.labelFontStyle)
                        .foregroundStyle(theme.colors.foreground.primary)
                } else {
                    Text(placeholder)
                        .fontStyle(size.labelFontStyle)
                        .foregroundStyle(theme.colors.foreground.muted)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(theme.colors.foreground.muted)
                    .rotationEffect(.degrees(isPresented ? 180 : 0))
            }
            .padding(.horizontal, theme.layout.spacing.medium)
            .padding(.vertical, theme.layout.spacing.small + 4)
            .background(theme.colors.surface.primary)
            .clipShape(RoundedRectangle(
                cornerRadius: theme.layout.radius.medium,
                style: .continuous,
            ))
            .overlay {
                RoundedRectangle(cornerRadius: theme.layout.radius.medium, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .disabled(configuration.isDisabled)
        .opacity(configuration.isDisabled ? theme.layout.opacity.disabled : 1)
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }) { frame in
            triggerGlobalFrame = frame
        }
        .superOverlay(isPresented) {
            DropdownOverlayContent(
                configuration: configuration,
                size: size,
                theme: theme,
                label: label,
                verticalPlacement: verticalPlacement,
                horizontalAlignment: horizontalAlignment,
                triggerGlobalFrame: triggerGlobalFrame,
                isPresented: $isPresented,
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    private var borderColor: Color {
        if configuration.isInvalid {
            return theme.colors.danger.default
        }
        if isPresented {
            return theme.colors.accent.default
        }
        return theme.colors.border
    }
}

// MARK: - DropdownOverlayContent

private struct DropdownOverlayContent: View {
    let configuration: SelectStyleConfiguration
    let size: SelectSize
    let theme: LegendTheme
    let label: String?
    let verticalPlacement: SelectVerticalPlacement
    let horizontalAlignment: SelectHorizontalAlignment
    let triggerGlobalFrame: CGRect
    @Binding var isPresented: Bool

    @State private var contentOpacity: Double = 0
    @State private var contentScale: Double = 0.95

    var body: some View {
        GeometryReader { geo in
            let triggerSize = geo.size
            let gap: CGFloat = 4

            // 자동 위치 결정
            let resolvedPlacement = resolveVerticalPlacement(
                triggerGlobalFrame: triggerGlobalFrame,
                gap: gap,
            )

            // alignment 결정 (top/bottom + leading/trailing 조합)
            let menuAlignment: Alignment = switch (resolvedPlacement, horizontalAlignment) {
            case (.bottom, .leading), (.auto, .leading):
                .topLeading
            case (.bottom, .trailing), (.auto, .trailing):
                .topTrailing
            case (.top, .leading):
                .bottomLeading
            case (.top, .trailing):
                .bottomTrailing
            }

            // Y 오프셋 계산
            let offsetY: CGFloat = switch resolvedPlacement {
            case .bottom, .auto:
                triggerSize.height + gap
            case .top:
                -triggerSize.height - gap
            }

            // 애니메이션 anchor
            let scaleAnchor: UnitPoint = resolvedPlacement == .top ? .bottom : .top

            // 메뉴 콘텐츠 (원래 bounds 기준)
            Color.clear
                .overlay(alignment: menuAlignment) {
                    DropdownMenuContent(
                        configuration: configuration,
                        size: size,
                        theme: theme,
                        label: label,
                        triggerWidth: triggerSize.width,
                    ) {
                        dismiss()
                    }
                    .offset(y: offsetY)
                    .opacity(contentOpacity)
                    .scaleEffect(contentScale, anchor: scaleAnchor)
                }
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
                .padding(-5000)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                contentOpacity = 1
                contentScale = 1
            }
        }
    }

    private func resolveVerticalPlacement(
        triggerGlobalFrame: CGRect,
        gap: CGFloat,
    ) -> SelectVerticalPlacement {
        guard verticalPlacement == .auto else { return verticalPlacement }

        // 크로스플랫폼 화면 높이 가져오기
        #if os(iOS)
            let screenHeight = UIScreen.main.bounds.height
        #else
            let screenHeight = NSScreen.main?.frame.height ?? 800
        #endif

        let spaceBelow = screenHeight - triggerGlobalFrame.maxY - gap
        let spaceAbove = triggerGlobalFrame.minY - gap

        // 더 넓은 쪽에 표시
        return spaceBelow >= spaceAbove ? .bottom : .top
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.15)) {
            contentOpacity = 0
            contentScale = 0.95
        } completion: {
            isPresented = false
        }
    }
}

// MARK: - DropdownMenuContent

private struct DropdownMenuContent: View {
    let configuration: SelectStyleConfiguration
    let size: SelectSize
    let theme: LegendTheme
    let label: String?
    let triggerWidth: CGFloat
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 라벨 헤더
            if let label {
                Text(label)
                    .fontStyle(size.descriptionFontStyle)
                    .foregroundStyle(theme.colors.foreground.muted)
                    .padding(.horizontal, theme.layout.spacing.medium)
                    .padding(.top, theme.layout.spacing.small)
                    .padding(.bottom, theme.layout.spacing.small + 2)
            }

            ForEach(configuration.items) { item in
                DropdownItemView(
                    item: item,
                    size: size,
                    isInvalid: configuration.isInvalid,
                    theme: theme,
                ) {
                    item.select()
                    dismiss()
                }

                if item.id != configuration.items.last?.id {
                    Divider()
                        .background(theme.colors.border)
                        .padding(.horizontal, theme.layout.spacing.medium)
                }
            }
        }
        .padding(.vertical, theme.layout.spacing.small)
        .frame(width: triggerWidth)
        .background(theme.colors.surface.primary)
        .clipShape(RoundedRectangle(
            cornerRadius: theme.layout.radius.medium,
            style: .continuous,
        ))
        .overlay {
            RoundedRectangle(cornerRadius: theme.layout.radius.medium, style: .continuous)
                .stroke(theme.colors.border, lineWidth: 1.5)
        }
        .shadow(
            color: .black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4,
        )
    }
}

// MARK: - DropdownItemView

private struct DropdownItemView: View {
    let item: SelectStyleConfiguration.Item
    let size: SelectSize
    let isInvalid: Bool
    let theme: LegendTheme
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: size.spacing) {
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

                Spacer(minLength: 16)

                Image(systemName: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.accent.default)
                    .opacity(item.isSelected ? 1 : 0)
            }
            .padding(.horizontal, theme.layout.spacing.medium)
            .padding(.vertical, theme.layout.spacing.small + 2)
            .background(isHovered ? theme.colors.surface.secondary : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        .onHover { hovering in
            isHovered = hovering
        }
        .opacity(item.isDisabled ? theme.layout.opacity.disabled : 1)
    }

    private var labelColor: Color {
        if item.isDisabled {
            return theme.colors.disabled.foreground
        }
        if item.isSelected {
            return theme.colors.accent.default
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - Style Extension

extension SelectStyle where Self == DropdownSelectStyle {
    /// Creates a dropdown style with custom configuration.
    ///
    /// - Note: This style does not work properly on macOS. Use ``PickerSelectStyle`` instead.
    ///
    /// - Parameters:
    ///   - size: The size preset for the dropdown. Defaults to `.md`.
    ///   - placeholder: Text shown when no option is selected. Defaults to "Select an option".
    ///   - label: Optional header label displayed above the menu options.
    ///   - placement: Vertical placement of the menu (`.top`, `.bottom`, `.auto`). Defaults to
    /// `.auto`.
    ///   - alignment: Horizontal alignment of the menu (`.leading`, `.trailing`). Defaults to
    /// `.leading`.
    public static func dropdown(
        size: SelectSizeType = .md,
        placeholder: String,
        label: String? = nil,
        placement: SelectVerticalPlacement = .auto,
        alignment: SelectHorizontalAlignment = .leading,
    ) -> DropdownSelectStyle {
        DropdownSelectStyle(
            size: size,
            placeholder: placeholder,
            label: label,
            placement: placement,
            alignment: alignment,
        )
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

    #Preview("Dropdown Style") {
        struct PreviewContainer: View {
            @State private var selected1: Fruit = .apple
            @State private var selected2: Fruit = .banana
            @State private var selected3: Fruit = .orange

            var fruitItems: [SelectItem<Fruit>] {
                [
                    SelectItem("Apple", value: .apple),
                    SelectItem("Banana", value: .banana),
                    SelectItem("Orange", value: .orange),
                    SelectItem("Grape", value: .grape),
                ]
            }

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        Color.clear.frame(height: 600)

                        // 기본 드롭다운 + 라벨
                        VStack(alignment: .leading, spacing: 8) {
                            Text("With Label (Auto Placement)")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Select(
                                selection: $selected1,
                                items: fruitItems,
                                style: .dropdown(
                                    placeholder: "Select a fruit",
                                    label: "Choose a fruit",
                                ),
                            )
                            .frame(width: 200)
                        }

                        // 위치: 위로 고정
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Placement: Top")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Select(
                                selection: $selected2,
                                items: fruitItems,
                                style: .dropdown(
                                    placeholder: "Select a fruit",
                                    placement: .top,
                                ),
                            )
                            .frame(width: 200)
                        }

                        // 정렬: 우측
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("Alignment: Trailing")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Select(
                                    selection: $selected3,
                                    items: fruitItems,
                                    style: .dropdown(
                                        placeholder: "Select a fruit",
                                        label: "Right aligned",
                                        alignment: .trailing,
                                    ),
                                )
                                .frame(width: 200)
                            }
                        }

                        Color.clear.frame(height: 1000)
                    }
                    .padding()
                }
            }
        }

        return PreviewContainer()
    }
#endif
