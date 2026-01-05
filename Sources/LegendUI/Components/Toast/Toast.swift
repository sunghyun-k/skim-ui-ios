import SwiftUI

// MARK: - Toast

// MARK: - Toast Type

/// The visual style of a toast notification.
public enum ToastType: Sendable {
    case `default`
    case success
    case warning
    case danger
}

// MARK: - Toast Value

/// A value that represents a toast notification.
///
/// Create a `ToastValue` and append it to your toast array to display a notification.
/// Remove it from the array to dismiss the toast.
///
/// - Note: Set `duration` to `nil` for a persistent toast that won't auto-dismiss.
public struct ToastValue: Equatable, Identifiable, Sendable {
    public let id: UUID
    let title: String
    let message: String?
    let type: ToastType
    let icon: String?
    let duration: TimeInterval?
    let showCloseButton: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        type: ToastType = .default,
        icon: String? = nil,
        duration: TimeInterval? = 3.0,
        showCloseButton: Bool = true,
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.icon = icon
        self.duration = duration
        self.showCloseButton = showCloseButton
    }

    public static func == (lhs: ToastValue, rhs: ToastValue) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toasts Modifier

private struct ToastsModifier: ViewModifier {
    @Binding var toasts: [ToastValue]
    let alignment: Alignment
    @State private var presentCover = false
    @State private var dismissingTask: Task<Void, any Error>?

    func body(content: Content) -> some View {
        content
            .onChange(of: toasts.isEmpty) { _, isEmpty in
                dismissingTask?.cancel()
                if isEmpty {
                    dismissingTask = Task {
                        try await Task.sleep(for: .seconds(0.5))
                        presentCover = false
                    }
                } else if !presentCover {
                    presentCover = true
                }
            }
            .nonAnimatedFullScreenCover(isPresented: $presentCover) {
                ToastOverlayView(toasts: $toasts, alignment: alignment)
            }
    }
}

// MARK: - Toast Overlay View

private struct ToastOverlayView: View {
    @Binding var toasts: [ToastValue]
    let alignment: Alignment
    @State private var appeared = false

    private var isBottom: Bool {
        alignment.vertical == .bottom
    }

    private var transitionOffset: CGFloat {
        isBottom ? 150 : -150
    }

    var body: some View {
        let presentingToasts = appeared ? toasts : []
        ZStack(alignment: alignment) {
            // 배경: 터치 통과
            Color.clear
                .ignoresSafeArea()

            // Toast 스택
            ZStack(alignment: alignment) {
                ForEach(presentingToasts) { item in
                    let indexFromTop = toasts.firstIndex(where: { $0.id == item.id })
                        .map { toasts.count - 1 - $0 }

                    SingleToastView(
                        toast: item,
                        indexFromTop: indexFromTop,
                        totalCount: toasts.count,
                        isBottom: isBottom,
                        onDismiss: { dismissToast(item.id) },
                    )
                    .hittable()
                    .transition(.offset(y: transitionOffset))
                }
            }
            .animation(.spring, value: presentingToasts.count)
            .padding(.horizontal, 16)
            .padding(.top, isBottom ? 0 : 8)
            .padding(.bottom, isBottom ? 8 : 0)
            .frame(maxWidth: .infinity, alignment: alignment)
        }
        .onAppear {
            appeared = true
            for toast in toasts {
                scheduleDismiss(for: toast)
            }
        }
        .onChange(of: toasts) { oldValue, newValue in
            let oldIds = Set(oldValue.map(\.id))
            for toast in newValue where !oldIds.contains(toast.id) {
                scheduleDismiss(for: toast)
            }
        }
    }

    private func scheduleDismiss(for toast: ToastValue) {
        guard let duration = toast.duration else { return }
        Task {
            try? await Task.sleep(for: .seconds(duration))
            dismissToast(toast.id)
        }
    }

    private func dismissToast(_ id: UUID) {
        withAnimation {
            toasts.removeAll { $0.id == id }
        }
    }
}

// MARK: - Single Toast View

private struct SingleToastView: View {
    @Environment(\.legendTheme) private var theme

    let toast: ToastValue
    let indexFromTop: Int?
    let totalCount: Int
    let isBottom: Bool
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    // 닫힐 때 zIndex가 역전되는 현상을 막기 위해 사용
    @State private var isDismissing = false

    private var isTopmost: Bool { indexFromTop == 0 }
    private var clampedIndex: CGFloat { CGFloat(min(indexFromTop ?? 0, 3)) }

    private var scale: CGFloat {
        1.0 - clampedIndex * 0.05
    }

    private var yOffset: CGFloat {
        let baseOffset = clampedIndex * 8
        return isBottom ? -baseOffset + dragOffset : baseOffset + dragOffset
    }

    private var opacity: CGFloat {
        if (indexFromTop ?? 0) > 3 { return 0 }
        return max(1.0 - clampedIndex * 0.15, 0.5)
    }

    private var iconName: String {
        if let icon = toast.icon { return icon }
        switch toast.type {
        case .default: return "bell.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch toast.type {
        case .default: theme.colors.foreground.secondary
        case .success: theme.colors.success.default
        case .warning: theme.colors.warning.default
        case .danger: theme.colors.danger.default
        }
    }

    var body: some View {
        HStack(spacing: theme.layout.spacing.small) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .fontStyle(theme.typography.sm.weight(.medium))
                    .foregroundStyle(theme.colors.surface.foreground)

                if let message = toast.message {
                    Text(message)
                        .fontStyle(theme.typography.xs)
                        .foregroundStyle(theme.colors.surface.foreground.opacity(0.7))
                }
            }

            Spacer()

            if toast.showCloseButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(theme.colors.surface.foreground.opacity(0.4))
                        .frame(width: 24, height: 24)
                        .background(theme.colors.surface.secondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, theme.layout.spacing.medium)
        .padding(.vertical, theme.layout.spacing.small + 4)
        .frame(maxWidth: 400)
        .background(theme.colors.surface.primary)
        .clipShape(RoundedRectangle(cornerRadius: theme.layout.radius.large, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .scaleEffect(scale)
        .offset(y: yOffset)
        .opacity(opacity)
        .zIndex(isDismissing ? 999 : Double(-(indexFromTop ?? 0)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isTopmost {
                        if isBottom {
                            dragOffset = max(0, value.translation.height)
                        } else {
                            dragOffset = min(0, value.translation.height)
                        }
                    }
                }
                .onEnded { value in
                    let shouldDismiss: Bool = if isBottom {
                        isTopmost && (value.translation.height > 50 || value.velocity.height > 300)
                    } else {
                        isTopmost &&
                            (value.translation.height < -50 || value.velocity.height < -300)
                    }
                    if shouldDismiss {
                        dismiss()
                    }
                    withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                        dragOffset = 0
                    }
                },
        )
        .animation(.spring(duration: 0.35, bounce: 0.15), value: indexFromTop)
    }

    private func dismiss() {
        isDismissing = true
        onDismiss()
    }
}

// MARK: - View Extension

extension View {
    /// Displays toast notifications from a binding array.
    ///
    /// Toasts are displayed when added to the array and dismissed when removed.
    /// Users can also dismiss toasts by swiping (up for top alignment, down for bottom).
    ///
    /// - Important: On macOS, this modifier must be applied to a view that covers the full screen
    ///   (e.g., the root view of your window). On iOS, it can be applied to any view.
    ///
    /// - Parameters:
    ///   - toasts: A binding to the array of toast values to display.
    ///   - alignment: The screen edge where toasts appear. Defaults to `.top`.
    ///                Use `.bottom` for bottom-aligned toasts.
    public func toasts(_ toasts: Binding<[ToastValue]>, alignment: Alignment = .top) -> some View {
        modifier(ToastsModifier(toasts: toasts, alignment: alignment))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Toast") {
        ToastPreview()
    }

    private struct ToastPreview: View {
        @State private var toasts: [ToastValue] = []

        var body: some View {
            ZStack {
                Color("background", bundle: .module)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Button("Add Toast") {
                        let types: [ToastType] = [.default, .success, .warning, .danger]
                        let messages = [
                            "New notification received",
                            "File uploaded successfully",
                            "Storage almost full",
                            "Connection lost",
                        ]
                        let randomIndex = Int.random(in: 0 ..< types.count)

                        toasts.append(ToastValue(
                            title: "Toast \(toasts.count + 1)",
                            message: messages[randomIndex],
                            type: types[randomIndex],
                            duration: 5.0,
                        ))
                    }
                    .buttonStyle(.legend(variant: .primary, size: .md, isFullWidth: false))

                    Button("Clear All") {
                        toasts.removeAll()
                    }
                    .buttonStyle(.legend(variant: .ghost, size: .sm, isFullWidth: false))

                    Text("Active toasts: \(toasts.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .toasts($toasts, alignment: .top)
        }
    }
#endif
