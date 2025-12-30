import SwiftUI

// MARK: - Dialog

// MARK: - Dialog Dismiss Environment

/// An action that dismisses the current dialog with animation.
///
/// Access this action via the environment to dismiss a dialog from any child view.
@MainActor
public struct DialogDismissAction: Sendable {
    let dismiss: () -> Void

    public func callAsFunction() {
        dismiss()
    }
}

private struct DialogDismissKey: EnvironmentKey {
    static let defaultValue: DialogDismissAction? = nil
}

extension EnvironmentValues {
    /// The action to dismiss the current dialog with animation.
    public var dismissDialog: DialogDismissAction? {
        get { self[DialogDismissKey.self] }
        set { self[DialogDismissKey.self] = newValue }
    }
}

// MARK: - Dialog Modifier

/// A view modifier that presents a modal dialog overlay.
///
/// This modifier handles the presentation and dismissal animations of the dialog.
/// Use the `.dialog(isPresented:)` view extension instead of applying this modifier directly.
public struct DialogModifier<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?
    var isDismissable: Bool
    var hasBackgroundBlur: Bool
    @ViewBuilder var dialogContent: () -> DialogContent

    @State private var internalIsPresented = false
    @State private var animationProgress: CGFloat = 0
    @State private var isClosing = false

    public init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        isDismissable: Bool = true,
        hasBackgroundBlur: Bool = false,
        @ViewBuilder content: @escaping () -> DialogContent,
    ) {
        _isPresented = isPresented
        self.onDismiss = onDismiss
        self.isDismissable = isDismissable
        self.hasBackgroundBlur = hasBackgroundBlur
        self.dialogContent = content
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    // 열기
                    internalIsPresented = true
                } else if !isClosing {
                    // 닫기 (애니메이션 후)
                    startCloseAnimation()
                }
            }
            .nonAnimatedFullScreenCover(isPresented: $internalIsPresented, onDismiss: onDismiss) {
                DialogContainer(
                    animationProgress: $animationProgress,
                    isDismissable: isDismissable,
                    hasBackgroundBlur: hasBackgroundBlur,
                    onDismiss: { startCloseAnimation() },
                    content: dialogContent,
                )
                .hittable()
            }
    }

    private func startCloseAnimation() {
        guard !isClosing else { return }
        isClosing = true

        withAnimation(.spring(duration: 0.25, bounce: 0)) {
            animationProgress = 0
        } completion: {
            internalIsPresented = false
            isPresented = false
            isClosing = false
        }
    }
}

// MARK: - Dialog Container

private struct DialogContainer<Content: View>: View {
    @Binding var animationProgress: CGFloat
    let isDismissable: Bool
    let hasBackgroundBlur: Bool
    let onDismiss: @MainActor () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            // Overlay
            Group {
                if hasBackgroundBlur {
                    Color.clear
                        .background(.ultraThinMaterial)
                } else {
                    Color.black
                        .opacity(0.2)
                }
            }
            .opacity(animationProgress)
            .ignoresSafeArea()
            .onTapGesture {
                if isDismissable {
                    onDismiss()
                }
            }

            // Content
            content()
                .scaleEffect(0.9 + 0.1 * animationProgress)
                .opacity(animationProgress)
                .offset(y: 20 * (1 - animationProgress))
        }
        .environment(\.dismissDialog, DialogDismissAction(dismiss: onDismiss))
        .onAppear {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                animationProgress = 1
            }
        }
    }
}

// MARK: - Dialog Content

/// A container view that provides the standard dialog styling.
///
/// Use this as the root container for your dialog content. It applies the appropriate
/// background, padding, corner radius, and shadow to match the design system.
public struct DialogContent<Content: View>: View {
    @Environment(\.legendTheme) private var theme

    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.layout.spacing.medium) {
            content()
        }
        .frame(maxWidth: 320)
        .padding(theme.layout.spacing.large)
        .background(theme.colors.surface.primary)
        .clipShape(RoundedRectangle(cornerRadius: theme.layout.radius.xLarge, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    }
}

// MARK: - Dialog Header

/// A header component for dialogs that displays a title and optional close button.
///
/// Place this at the top of your `DialogContent` to provide a consistent header layout.
public struct DialogHeader: View {
    @Environment(\.legendTheme) private var theme
    @Environment(\.dismissDialog) private var dismiss

    let title: String
    var showCloseButton: Bool

    public init(
        title: String,
        showCloseButton: Bool = false,
    ) {
        self.title = title
        self.showCloseButton = showCloseButton
    }

    public var body: some View {
        HStack {
            Text(title)
                .fontStyle(theme.typography.lg)
                .foregroundStyle(theme.colors.surface.foreground)

            Spacer()

            if showCloseButton {
                Button {
                    dismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.colors.surface.foreground.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(theme.colors.surface.secondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Dialog Body

/// A container for the main content of a dialog.
///
/// This view applies the standard text styling for dialog body content.
public struct DialogBody<Content: View>: View {
    @Environment(\.legendTheme) private var theme

    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .fontStyle(theme.typography.base)
            .foregroundStyle(theme.colors.surface.foreground.opacity(0.7))
    }
}

// MARK: - Dialog Footer

/// A container for dialog action buttons.
///
/// Place action buttons inside this view. Buttons are right-aligned by default.
public struct DialogFooter<Content: View>: View {
    @Environment(\.legendTheme) private var theme

    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack(spacing: theme.layout.spacing.small) {
            Spacer()
            content()
        }
        .padding(.top, theme.layout.spacing.small)
    }
}

// MARK: - Dialog Close Button

/// A pre-configured button that dismisses the dialog when tapped.
///
/// This button automatically uses the `dismissDialog` environment action
/// to close the dialog with the proper animation.
public struct DialogCloseButton: View {
    @Environment(\.dismissDialog) private var dismiss

    let title: String
    var variant: ButtonVariantType
    var size: ButtonSizeType

    public init(
        _ title: String,
        variant: ButtonVariantType = .ghost,
        size: ButtonSizeType = .sm,
    ) {
        self.title = title
        self.variant = variant
        self.size = size
    }

    public var body: some View {
        Button(title) {
            dismiss?()
        }
        .buttonStyle(.legend(variant: variant, size: size, isFullWidth: false))
    }
}

// MARK: - View Extension

extension View {
    /// Presents a modal dialog overlay.
    ///
    /// - Important: On macOS, this modifier must be applied to a view that covers the full screen
    ///   (e.g., the root view of your window). On iOS, it can be applied to any view.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean that determines whether to present the dialog.
    ///   - onDismiss: A closure called when the dialog is dismissed.
    ///   - isDismissable: Whether tapping the background dismisses the dialog. Defaults to `true`.
    ///   - hasBackgroundBlur: Whether to apply a blur effect to the background. Defaults to
    /// `false`.
    ///   - content: The dialog content to display.
    public func dialog(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        isDismissable: Bool = true,
        hasBackgroundBlur: Bool = false,
        @ViewBuilder content: @escaping () -> some View,
    ) -> some View {
        modifier(DialogModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            isDismissable: isDismissable,
            hasBackgroundBlur: hasBackgroundBlur,
            content: content,
        ))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Dialog") {
        @Previewable @State var showBasicDialog = false
        @Previewable @State var showFormDialog = false
        @Previewable @State var showDeleteDialog = false
        @Previewable @State var email = ""
        @Previewable @State var agreeToTerms = false

        ZStack {
            Color("background", bundle: .module)
                .ignoresSafeArea()

            // 배경 무작위 요소들
            GeometryReader { geometry in
                ForEach(0 ..< 15, id: \.self) { index in
                    let x = CGFloat.random(in: 0 ... geometry.size.width)
                    let y = CGFloat.random(in: 0 ... geometry.size.height)
                    let rotation = Double.random(in: -30 ... 30)
                    let opacity = Double.random(in: 0.1 ... 0.3)

                    Group {
                        if index % 3 == 0 {
                            Text([
                                "Hello",
                                "SwiftUI",
                                "LegendUI",
                                "Dialog",
                                "Modal",
                                "Preview",
                            ][index % 6])
                                .font(.system(size: CGFloat.random(in: 12 ... 24)))
                        } else if index % 3 == 1 {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .frame(
                                    width: CGFloat.random(in: 40 ... 80),
                                    height: CGFloat.random(in: 20 ... 40),
                                )
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: CGFloat.random(in: 20 ... 50))
                        }
                    }
                    .position(x: x, y: y)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
                }
            }

            // 버튼들
            VStack(spacing: 12) {
                Button("Basic") {
                    showBasicDialog = true
                }
                .buttonStyle(.legend(variant: .primary, size: .md, isFullWidth: false))

                Button("Form (isDismissable: false)") {
                    showFormDialog = true
                }
                .buttonStyle(.legend(variant: .secondary, size: .md, isFullWidth: false))

                Button("Delete (blur)") {
                    showDeleteDialog = true
                }
                .buttonStyle(.legend(variant: .danger, size: .md, isFullWidth: false))
            }
        }
        .dialog(isPresented: $showBasicDialog) {
            DialogContent {
                DialogHeader(
                    title: "Confirm Action",
                    showCloseButton: true,
                )

                DialogBody {
                    Text(
                        "Are you sure you want to proceed with this action? This cannot be undone.",
                    )
                }

                DialogFooter {
                    DialogCloseButton("Cancel")

                    Button("Confirm") {
                        showBasicDialog = false
                    }
                    .buttonStyle(.legend(variant: .primary, size: .sm, isFullWidth: false))
                }
            }
        }
        .dialog(isPresented: $showFormDialog, isDismissable: false) {
            DialogContent {
                DialogHeader(
                    title: "Newsletter",
                    showCloseButton: true,
                )

                DialogBody {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Subscribe to our newsletter to get the latest updates.")

                        TextInput(
                            "Email",
                            text: $email,
                            prompt: "your@email.com",
                            size: .sm,
                        )

                        Toggle("I agree to the terms and conditions", isOn: $agreeToTerms)
                            .toggleStyle(.legendCheckbox(size: .sm))
                    }
                }

                DialogFooter {
                    DialogCloseButton("Cancel")

                    Button("Subscribe") {
                        showFormDialog = false
                    }
                    .buttonStyle(.legend(variant: .primary, size: .sm, isFullWidth: false))
                    .disabled(!agreeToTerms || email.isEmpty)
                }
            }
        }
        .dialog(isPresented: $showDeleteDialog, hasBackgroundBlur: true) {
            DialogContent {
                DialogHeader(title: "Delete Account")

                DialogBody {
                    Text(
                        "This will permanently delete your account and all associated data. This action cannot be undone.",
                    )
                }

                DialogFooter {
                    DialogCloseButton("Cancel")

                    Button("Delete") {
                        showDeleteDialog = false
                    }
                    .buttonStyle(.legend(variant: .danger, size: .sm, isFullWidth: false))
                }
            }
        }
    }
#endif
