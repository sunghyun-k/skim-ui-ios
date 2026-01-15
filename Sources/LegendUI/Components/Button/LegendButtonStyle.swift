import SwiftUI

// MARK: - LegendButtonStyle

/// A button style that applies LegendUI theming to any SwiftUI Button.
///
/// Use this style with the `.buttonStyle()` modifier to apply LegendUI styling:
/// ```swift
/// Button("Click me") { }
///     .buttonStyle(.legend(variant: .primary))
/// ```
public struct LegendButtonStyle: PrimitiveButtonStyle {
    private let variantType: ButtonVariantType?
    private let customVariant: ButtonVariant?
    private let sizeType: ButtonSizeType?
    private let customSize: ButtonSize?
    private let isIconOnly: Bool
    private let isFullWidth: Bool

    /// Creates a button style with predefined variant and size.
    ///
    /// - Parameters:
    ///   - variant: The visual style variant. Defaults to `.primary`.
    ///   - size: The size preset. Defaults to `.md`.
    ///   - isIconOnly: Whether the button displays only an icon. Defaults to `false`.
    ///   - isFullWidth: Whether the button expands to fill available width. Defaults to `true`.
    public init(
        variant: ButtonVariantType = .primary,
        size: ButtonSizeType = .md,
        isIconOnly: Bool = false,
        isFullWidth: Bool = true,
    ) {
        self.variantType = variant
        self.customVariant = nil
        self.sizeType = size
        self.customSize = nil
        self.isIconOnly = isIconOnly
        self.isFullWidth = isFullWidth
    }

    /// Creates a button style with a custom variant configuration.
    ///
    /// - Parameters:
    ///   - customVariant: A custom variant configuration defining colors for all states.
    ///   - size: The size preset. Defaults to `.md`.
    ///   - isIconOnly: Whether the button displays only an icon. Defaults to `false`.
    ///   - isFullWidth: Whether the button expands to fill available width. Defaults to `true`.
    public init(
        customVariant: ButtonVariant,
        size: ButtonSizeType = .md,
        isIconOnly: Bool = false,
        isFullWidth: Bool = true,
    ) {
        self.variantType = nil
        self.customVariant = customVariant
        self.sizeType = size
        self.customSize = nil
        self.isIconOnly = isIconOnly
        self.isFullWidth = isFullWidth
    }

    /// Creates a button style with a custom size configuration.
    ///
    /// - Parameters:
    ///   - variant: The visual style variant. Defaults to `.primary`.
    ///   - customSize: A custom size configuration defining padding, spacing, and corner radius.
    ///   - isIconOnly: Whether the button displays only an icon. Defaults to `false`.
    ///   - isFullWidth: Whether the button expands to fill available width. Defaults to `true`.
    public init(
        variant: ButtonVariantType = .primary,
        customSize: ButtonSize,
        isIconOnly: Bool = false,
        isFullWidth: Bool = true,
    ) {
        self.variantType = variant
        self.customVariant = nil
        self.sizeType = nil
        self.customSize = customSize
        self.isIconOnly = isIconOnly
        self.isFullWidth = isFullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        LegendButtonStyleView(
            configuration: configuration,
            variantType: variantType,
            customVariant: customVariant,
            sizeType: sizeType,
            customSize: customSize,
            isIconOnly: isIconOnly,
            isFullWidth: isFullWidth,
        )
    }
}

// MARK: - ButtonStyle Extension

extension PrimitiveButtonStyle where Self == LegendButtonStyle {
    /// The default LegendUI button style with primary variant and medium size.
    public static var legend: LegendButtonStyle {
        LegendButtonStyle()
    }

    /// Creates a LegendUI button style with specified variant and size.
    ///
    /// - Parameters:
    ///   - variant: The visual style variant. Defaults to `.primary`.
    ///   - size: The size preset. Defaults to `.md`.
    ///   - isIconOnly: Whether the button displays only an icon. Defaults to `false`.
    ///   - isFullWidth: Whether the button expands to fill available width. Defaults to `true`.
    /// - Returns: A configured `LegendButtonStyle`.
    public static func legend(
        variant: ButtonVariantType = .primary,
        size: ButtonSizeType = .md,
        isIconOnly: Bool = false,
        isFullWidth: Bool = true,
    ) -> LegendButtonStyle {
        LegendButtonStyle(
            variant: variant,
            size: size,
            isIconOnly: isIconOnly,
            isFullWidth: isFullWidth,
        )
    }

    /// Creates a LegendUI button style with a custom variant configuration.
    ///
    /// - Parameters:
    ///   - customVariant: A custom variant configuration defining colors for all states.
    ///   - size: The size preset. Defaults to `.md`.
    ///   - isIconOnly: Whether the button displays only an icon. Defaults to `false`.
    ///   - isFullWidth: Whether the button expands to fill available width. Defaults to `true`.
    /// - Returns: A configured `LegendButtonStyle`.
    public static func legend(
        customVariant: ButtonVariant,
        size: ButtonSizeType = .md,
        isIconOnly: Bool = false,
        isFullWidth: Bool = true,
    ) -> LegendButtonStyle {
        LegendButtonStyle(
            customVariant: customVariant,
            size: size,
            isIconOnly: isIconOnly,
            isFullWidth: isFullWidth,
        )
    }
}

// MARK: - LegendButtonStyleView

private struct LegendButtonStyleView: View {
    let configuration: PrimitiveButtonStyle.Configuration
    let variantType: ButtonVariantType?
    let customVariant: ButtonVariant?
    let sizeType: ButtonSizeType?
    let customSize: ButtonSize?
    let isIconOnly: Bool
    let isFullWidth: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.legendTheme) private var theme

    @State private var isPressed = false
    @State private var isHovered = false

    private var variant: ButtonVariant {
        if let customVariant {
            return customVariant
        }
        return .resolved(variantType ?? .primary, theme: theme)
    }

    private var size: ButtonSize {
        if let customSize {
            return customSize
        }
        return .resolved(sizeType ?? .md, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            configuration.label
        }
        .fontStyle(size.fontStyle)
        .foregroundStyle(foregroundColor(isPressed: isPressed))
        .padding(.vertical, isIconOnly ? size.iconOnlyPadding : size.verticalPadding)
        .padding(.horizontal, isIconOnly ? size.iconOnlyPadding : size.horizontalPadding)
        .frame(maxWidth: isFullWidth && !isIconOnly ? .infinity : nil)
        .contentShape(Rectangle())
        .background {
            backgroundView(isPressed: isPressed)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        #if os(iOS)
        .overlay {
            LegendButtonGestureView(
                isEnabled: isEnabled,
                onPressChanged: { pressed in
                    isPressed = pressed
                },
                onTap: {
                    configuration.trigger()
                },
            )
        }
        #else
        .onTapGesture {
                    if isEnabled {
                        configuration.trigger()
                    }
                }
                .onLongPressGesture(
                    minimumDuration: 0,
                    pressing: { pressing in
                        isPressed = pressing
                    },
                    perform: {},
                )
        #endif
    }

    // MARK: - Foreground Color

    private func foregroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return variant.disabledForegroundColor
        }
        if isPressed, let pressedColor = variant.pressedForegroundColor {
            return pressedColor
        }
        if isHovered, let hoverColor = variant.hoverForegroundColor {
            return hoverColor
        }
        return variant.foregroundColor
    }

    // MARK: - Background View

    @ViewBuilder
    private func backgroundView(isPressed: Bool) -> some View {
        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
            .fill(backgroundColor(isPressed: isPressed))
            .overlay {
                if let borderColor = borderColor(isPressed: isPressed) {
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 1.5)
                }
            }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return variant.disabledBackgroundColor ?? .clear
        }
        if isPressed, let pressedColor = variant.pressedBackgroundColor {
            return pressedColor
        }
        if isHovered, let hoverColor = variant.hoverBackgroundColor {
            return hoverColor
        }
        return variant.backgroundColor ?? .clear
    }

    private func borderColor(isPressed: Bool) -> Color? {
        if !isEnabled {
            return variant.disabledBorderColor
        }
        if isPressed, let pressedColor = variant.pressedBorderColor {
            return pressedColor
        }
        if isHovered, let hoverColor = variant.hoverBorderColor {
            return hoverColor
        }
        return variant.borderColor
    }
}

// MARK: - iOS Press Gesture

#if os(iOS)
    import UIKit

    private struct LegendButtonGestureView: UIViewRepresentable {
        let isEnabled: Bool
        let onPressChanged: (Bool) -> Void
        let onTap: () -> Void

        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear

            let longPressGesture = UILongPressGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleLongPress(_:)),
            )
            longPressGesture.minimumPressDuration = 0
            longPressGesture.delegate = context.coordinator

            view.addGestureRecognizer(longPressGesture)
            return view
        }

        func updateUIView(_: UIView, context: Context) {
            context.coordinator.isEnabled = isEnabled
            context.coordinator.onPressChanged = onPressChanged
            context.coordinator.onTap = onTap
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(isEnabled: isEnabled, onPressChanged: onPressChanged, onTap: onTap)
        }

        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var isEnabled: Bool
            var onPressChanged: (Bool) -> Void
            var onTap: () -> Void

            private var initialFrameInWindow: CGRect?

            init(
                isEnabled: Bool,
                onPressChanged: @escaping (Bool) -> Void,
                onTap: @escaping () -> Void,
            ) {
                self.isEnabled = isEnabled
                self.onPressChanged = onPressChanged
                self.onTap = onTap
            }

            @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
                guard isEnabled, let view = gesture.view, let window = view.window else { return }
                let locationInWindow = gesture.location(in: window)

                switch gesture.state {
                case .began:
                    initialFrameInWindow = view.convert(view.bounds, to: window)
                    onPressChanged(true)
                case .changed:
                    guard let frame = initialFrameInWindow else { return }
                    if !frame.contains(locationInWindow) {
                        initialFrameInWindow = nil
                        onPressChanged(false)
                        return
                    }
                    onPressChanged(true)
                case .ended:
                    let shouldTrigger = initialFrameInWindow?.contains(locationInWindow) == true
                    initialFrameInWindow = nil
                    onPressChanged(false)
                    if shouldTrigger {
                        onTap()
                    }
                case .cancelled, .failed:
                    initialFrameInWindow = nil
                    onPressChanged(false)
                default:
                    break
                }
            }

            func gestureRecognizer(
                _: UIGestureRecognizer,
                shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer,
            ) -> Bool {
                true
            }
        }
    }
#endif

// MARK: - Preview

#if DEBUG
    #Preview("Variants (Light)") {
        ScrollView {
            let vstack = VStack(spacing: 16) {
                Button("Primary") { print("hello") }
                    .buttonStyle(.legend(variant: .primary))
                Button("Secondary") { print("hello") }
                    .buttonStyle(.legend(variant: .secondary))
                Button("Tertiary") { print("hello") }
                    .buttonStyle(.legend(variant: .tertiary))
                Button("Ghost") { print("hello") }
                    .buttonStyle(.legend(variant: .ghost))
                Button("Danger") { print("hello") }
                    .buttonStyle(.legend(variant: .danger))
                Button("Danger Soft") { print("hello") }
                    .buttonStyle(.legend(variant: .dangerSoft))
            }
            .padding()

            vstack
            vstack
            vstack
            vstack
        }
        .preferredColorScheme(.light)
    }

    #Preview("Variants (Dark)") {
        ScrollView {
            VStack(spacing: 16) {
                Button("Primary") {}
                    .buttonStyle(.legend(variant: .primary))
                Button("Secondary") {}
                    .buttonStyle(.legend(variant: .secondary))
                Button("Tertiary") {}
                    .buttonStyle(.legend(variant: .tertiary))
                Button("Ghost") {}
                    .buttonStyle(.legend(variant: .ghost))
                Button("Danger") {}
                    .buttonStyle(.legend(variant: .danger))
                Button("Danger Soft") {}
                    .buttonStyle(.legend(variant: .dangerSoft))
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }

    #Preview("Sizes") {
        VStack(spacing: 16) {
            Button("Small") {}
                .buttonStyle(.legend(size: .sm))
            Button("Medium") {}
                .buttonStyle(.legend(size: .md))
            Button("Large") {}
                .buttonStyle(.legend(size: .lg))
        }
        .padding()
    }

    #Preview("With Icons") {
        VStack(spacing: 16) {
            Button {} label: {
                Label("Add Item", systemImage: "plus")
            }
            .buttonStyle(.legend())

            Button {} label: {
                Label("Download", systemImage: "arrow.down.circle")
            }
            .buttonStyle(.legend(variant: .secondary))

            Button {} label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.legend(variant: .danger, size: .sm))
        }
        .padding()
    }

    #Preview("Icon Only") {
        HStack(spacing: 16) {
            Button {} label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.legend(size: .sm, isIconOnly: true))

            Button {} label: {
                Image(systemName: "heart.fill")
            }
            .buttonStyle(.legend(variant: .secondary, size: .md, isIconOnly: true))

            Button {} label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.legend(variant: .danger, size: .lg, isIconOnly: true))
        }
        .padding()
    }

    #Preview("Disabled") {
        VStack(spacing: 16) {
            Button("Disabled Primary") {}
                .buttonStyle(.legend())
                .disabled(true)
            Button("Disabled Secondary") {}
                .buttonStyle(.legend(variant: .secondary))
                .disabled(true)
            Button("Disabled Tertiary") {}
                .buttonStyle(.legend(variant: .tertiary))
                .disabled(true)
        }
        .padding()
    }

    #Preview("Custom Variant") {
        let purpleVariant = ButtonVariant(
            foregroundColor: .white,
            backgroundColor: .purple,
            pressedBackgroundColor: .purple.opacity(0.8),
            disabledForegroundColor: .gray,
            disabledBackgroundColor: .gray.opacity(0.3),
        )

        VStack(spacing: 16) {
            Button("Custom Purple") {}
                .buttonStyle(.legend(customVariant: purpleVariant))
        }
        .padding()
    }
#endif
