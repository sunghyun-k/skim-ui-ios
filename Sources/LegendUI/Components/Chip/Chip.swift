import SwiftUI

// MARK: - Chip

/// A customizable chip component with support for various visual styles and interactions.
///
/// Chip displays a label with optional start/end content, avatars, and close buttons.
/// It supports multiple variants (solid, bordered, flat, etc.) and semantic colors.
public struct Chip<Content: View, StartContent: View, EndContent: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.legendTheme) private var theme

    private let content: Content
    private let startContent: StartContent?
    private let endContent: EndContent?
    private let variantType: ChipVariantType
    private let colorType: ChipColorType
    private let sizeType: ChipSizeType
    private let radiusType: ChipRadiusType
    private let onTap: (() -> Void)?
    private let onClose: (() -> Void)?

    private var isInteractive: Bool { onTap != nil }

    @State private var isHovered = false
    @State private var isPressed = false

    public init(
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder startContent: () -> StartContent,
        @ViewBuilder endContent: () -> EndContent,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = content()
        self.startContent = startContent()
        self.endContent = endContent()
    }

    private var chipVariant: ChipVariant {
        .resolved(variant: variantType, color: colorType, theme: theme)
    }

    private var chipSize: ChipSize {
        .resolved(sizeType, radius: radiusType, layout: theme.layout, typography: theme.typography)
    }

    public var body: some View {
        HStack(spacing: chipSize.spacing) {
            // Dot indicator for dot variant
            if variantType == .dot, let dotColor = chipVariant.dotColor {
                Circle()
                    .fill(dotColor)
                    .frame(width: chipSize.dotSize, height: chipSize.dotSize)
            }

            // Start content
            if let startContent {
                startContent
            }

            // Main content
            content
                .fontStyle(chipSize.fontStyle)

            // End content
            if let endContent {
                endContent
            }

            // Close button
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: chipSize.closeButtonSize * 0.7, weight: .medium))
                        .frame(width: chipSize.closeButtonSize, height: chipSize.closeButtonSize)
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.vertical, chipSize.verticalPadding)
        .padding(.horizontal, chipSize.horizontalPadding)
        .background {
            backgroundView
        }
        .contentShape(Capsule())
        .scaleEffect(isInteractive && isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            guard isInteractive else { return }
            isHovered = hovering
        }
        .onTapGesture {
            onTap?()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard isInteractive else { return }
                    isPressed = true
                }
                .onEnded { _ in
                    guard isInteractive else { return }
                    isPressed = false
                },
        )
    }

    // MARK: - Foreground Color

    private var foregroundColor: Color {
        if !isEnabled {
            return chipVariant.disabledForegroundColor
        }
        return chipVariant.foregroundColor
    }

    // MARK: - Background View

    @ViewBuilder
    private var backgroundView: some View {
        let shape = RoundedRectangle(
            cornerRadius: chipSize.cornerRadius,
            style: .continuous,
        )

        shape
            .fill(backgroundColor)
            .overlay {
                if let borderColor {
                    shape.stroke(borderColor, lineWidth: 1.5)
                }
            }
            .shadow(
                color: chipVariant.shadowColor ?? .clear,
                radius: chipVariant.shadowRadius,
                x: 0,
                y: chipVariant.shadowRadius > 0 ? 4 : 0,
            )
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return chipVariant.disabledBackgroundColor
        }
        if isPressed, let pressedColor = chipVariant.pressedBackgroundColor {
            return pressedColor
        }
        if isHovered, let hoverColor = chipVariant.hoverBackgroundColor {
            return hoverColor
        }
        return chipVariant.backgroundColor
    }

    private var borderColor: Color? {
        if !isEnabled {
            return nil
        }
        return chipVariant.borderColor
    }
}

// MARK: - Convenience Initializers (No start/end content)

extension Chip where StartContent == EmptyView, EndContent == EmptyView {
    /// Creates a chip with custom content and no start/end decorations.
    ///
    /// - Parameters:
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    ///   - content: A view builder for the chip's main content.
    public init(
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = content()
        self.startContent = nil
        self.endContent = nil
    }
}

// MARK: - Text Content

extension Chip where Content == Text, StartContent == EmptyView, EndContent == EmptyView {
    /// Creates a chip with a text label.
    ///
    /// - Parameters:
    ///   - title: The text to display in the chip.
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    public init(
        _ title: String,
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = Text(title)
        self.startContent = nil
        self.endContent = nil
    }
}

// MARK: - With Start Content Only

extension Chip where EndContent == EmptyView {
    /// Creates a chip with custom content and a leading decoration.
    ///
    /// - Parameters:
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    ///   - content: A view builder for the chip's main content.
    ///   - startContent: A view builder for the leading decoration.
    public init(
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder startContent: () -> StartContent,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = content()
        self.startContent = startContent()
        self.endContent = nil
    }
}

// MARK: - With End Content Only

extension Chip where StartContent == EmptyView {
    /// Creates a chip with custom content and a trailing decoration.
    ///
    /// - Parameters:
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    ///   - content: A view builder for the chip's main content.
    ///   - endContent: A view builder for the trailing decoration.
    public init(
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder endContent: () -> EndContent,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = content()
        self.startContent = nil
        self.endContent = endContent()
    }
}

// MARK: - With Avatar

extension Chip where Content == Text, StartContent == AnyView, EndContent == EmptyView {
    /// Creates a chip with a text label and a system image avatar.
    ///
    /// - Parameters:
    ///   - title: The text to display in the chip.
    ///   - avatarSystemImage: The SF Symbol name for the avatar.
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    public init(
        _ title: String,
        avatarSystemImage: String,
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = Text(title)
        self.startContent = AnyView(
            ChipAvatarView(systemImage: avatarSystemImage, size: size),
        )
        self.endContent = nil
    }

    /// Creates a chip with a text label and a custom image avatar.
    ///
    /// - Parameters:
    ///   - title: The text to display in the chip.
    ///   - avatarImage: The image to use as the avatar.
    ///   - variant: The visual style of the chip. Defaults to `.solid`.
    ///   - color: The semantic color of the chip. Defaults to `.default`.
    ///   - size: The size of the chip. Defaults to `.md`.
    ///   - radius: The corner radius style. Defaults to `.full`.
    ///   - onTap: Optional tap action to make the chip interactive.
    ///   - onClose: Optional close action to show a dismiss button.
    public init(
        _ title: String,
        avatarImage: Image,
        variant: ChipVariantType = .solid,
        color: ChipColorType = .default,
        size: ChipSizeType = .md,
        radius: ChipRadiusType = .full,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
    ) {
        self.variantType = variant
        self.colorType = color
        self.sizeType = size
        self.radiusType = radius
        self.onTap = onTap
        self.onClose = onClose
        self.content = Text(title)
        self.startContent = AnyView(
            ChipAvatarView(image: avatarImage, size: size),
        )
        self.endContent = nil
    }
}

// MARK: - Avatar View

private struct ChipAvatarView: View {
    @Environment(\.legendTheme) private var theme

    let image: Image?
    let systemImage: String?
    let sizeType: ChipSizeType

    init(systemImage: String, size: ChipSizeType) {
        self.systemImage = systemImage
        self.image = nil
        self.sizeType = size
    }

    init(image: Image, size: ChipSizeType) {
        self.image = image
        self.systemImage = nil
        self.sizeType = size
    }

    private var avatarSize: CGFloat {
        ChipSize.resolved(
            sizeType,
            radius: .full,
            layout: theme.layout,
            typography: theme.typography,
        ).avatarSize
    }

    var body: some View {
        Group {
            if let systemImage {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .padding(avatarSize * 0.2)
            } else if let image {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .clipShape(Circle())
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Variants") {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Chip("Solid", variant: .solid, color: .primary)
                    Chip("Bordered", variant: .bordered, color: .primary)
                    Chip("Light", variant: .light, color: .primary)
                }
                HStack(spacing: 8) {
                    Chip("Flat", variant: .flat, color: .primary)
                    Chip("Faded", variant: .faded, color: .primary)
                    Chip("Shadow", variant: .shadow, color: .primary)
                }
                HStack(spacing: 8) {
                    Chip("Dot", variant: .dot, color: .primary)
                    Chip("Dot Success", variant: .dot, color: .success)
                    Chip("Dot Danger", variant: .dot, color: .danger)
                }
            }
            .padding()
        }
    }

    #Preview("Colors") {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Chip("Default", color: .default)
                    Chip("Primary", color: .primary)
                    Chip("Secondary", color: .secondary)
                }
                HStack(spacing: 8) {
                    Chip("Success", color: .success)
                    Chip("Warning", color: .warning)
                    Chip("Danger", color: .danger)
                }
            }
            .padding()
        }
    }

    #Preview("Sizes") {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Chip("Small", size: .sm)
                Chip("Medium", size: .md)
                Chip("Large", size: .lg)
            }
        }
        .padding()
    }

    #Preview("Radius") {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Chip("None", radius: .none)
                Chip("Small", radius: .sm)
                Chip("Medium", radius: .md)
            }
            HStack(spacing: 8) {
                Chip("Large", radius: .lg)
                Chip("Full", radius: .full)
            }
        }
        .padding()
    }

    #Preview("With Close Button") {
        VStack(spacing: 16) {
            Chip("Closable", color: .primary, onClose: {})
            Chip("Closable Success", variant: .flat, color: .success, onClose: {})
            Chip("Closable Bordered", variant: .bordered, color: .danger, onClose: {})
        }
        .padding()
    }

    #Preview("With Avatar") {
        VStack(spacing: 16) {
            Chip("John Doe", avatarSystemImage: "person.fill", color: .primary)
            Chip(
                "Jane Smith",
                avatarSystemImage: "person.circle.fill",
                variant: .flat,
                color: .success,
            )
            Chip("With Close", avatarSystemImage: "star.fill", color: .warning, onClose: {})
        }
        .padding()
    }

    #Preview("Disabled") {
        VStack(spacing: 16) {
            Chip("Disabled Solid", color: .primary)
                .disabled(true)
            Chip("Disabled Bordered", variant: .bordered, color: .primary)
                .disabled(true)
            Chip("Disabled Flat", variant: .flat, color: .success)
                .disabled(true)
        }
        .padding()
    }

    #Preview("Custom Content") {
        VStack(spacing: 16) {
            Chip(variant: .flat, color: .primary) {
                Text("Custom")
            } startContent: {
                Image(systemName: "star.fill")
            }

            Chip(variant: .bordered, color: .success) {
                Text("Status")
            } endContent: {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
            }

            Chip(variant: .solid, color: .warning) {
                Text("Both")
            } startContent: {
                Image(systemName: "bolt.fill")
            } endContent: {
                Text("!")
                    .fontWeight(.bold)
            }
        }
        .padding()
    }

    #Preview("Interactive (onTap)") {
        VStack(spacing: 16) {
            Chip("Tappable", color: .primary, onTap: {})
            Chip("Filter", variant: .bordered, color: .secondary, onTap: {})
            Chip("Both", color: .success, onTap: {}, onClose: {})
        }
        .padding()
    }

    #Preview("Dark Mode") {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Chip("Solid", variant: .solid, color: .primary)
                    Chip("Bordered", variant: .bordered, color: .primary)
                    Chip("Flat", variant: .flat, color: .primary)
                }
                HStack(spacing: 8) {
                    Chip("Success", color: .success)
                    Chip("Warning", color: .warning)
                    Chip("Danger", color: .danger)
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
#endif
