import SwiftUI
import UIKit

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
/// Pass a `ToastValue` to the `presentToast` environment action to display a notification.
///
/// - Note: Set `duration` to `nil` for a persistent toast that won't auto-dismiss.
/// - Note: `type` picks the badge color; `icon` replaces the glyph inside it.
///   `systemImage` is kept for SF Symbols but prefer `icon`.
/// - Note: A title-only toast without a close button is a compact capsule; anything more is a card.
public struct ToastValue: Equatable, Identifiable, Sendable {
    public let id: UUID
    let title: String
    let message: String?
    let type: ToastType
    let icon: Icon?
    let systemImage: String?
    let duration: TimeInterval?
    let showCloseButton: Bool

    var isCompact: Bool {
        message == nil && !showCloseButton
    }

    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        type: ToastType = .default,
        icon: Icon? = nil,
        systemImage: String? = nil,
        duration: TimeInterval? = 3.0,
        showCloseButton: Bool? = nil,
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.icon = icon
        self.systemImage = systemImage
        self.duration = duration
        // 기본값: 저절로 닫히지 않을 때만 닫기 버튼을 둔다.
        self.showCloseButton = showCloseButton ?? (duration == nil)
    }

    public static func == (lhs: ToastValue, rhs: ToastValue) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Present Toast Action

/// Shows a toast above every window of the scene. Read it from the environment:
///
/// ```swift
/// @Environment(\.presentToast) private var presentToast
/// presentToast(ToastValue(title: "Saved", type: .success))
/// ```
///
/// - Important: Call `installToasts()` once on the scene's root view. Without it, nothing appears.
@MainActor
public struct PresentToastAction {
    private weak var center: ToastCenter?

    nonisolated init() {}

    init(center: ToastCenter) {
        self.center = center
    }

    /// Shows `toast` on top of the toasts already showing.
    public func callAsFunction(_ toast: ToastValue) {
        #if DEBUG
            if center == nil {
                print("SkimUI: call installToasts() on the root view to use presentToast.")
            }
        #endif
        center?.present(toast)
    }

    /// Dismisses the toast with `id`. Use it for persistent toasts (`duration: nil`).
    public func dismiss(_ id: ToastValue.ID) {
        center?.dismiss(id)
    }
}

private struct PresentToastKey: EnvironmentKey {
    static let defaultValue = PresentToastAction()
}

extension EnvironmentValues {
    /// Shows a toast. Available below a view that called `installToasts()`.
    public internal(set) var presentToast: PresentToastAction {
        get { self[PresentToastKey.self] }
        set { self[PresentToastKey.self] = newValue }
    }
}

// MARK: - Toast Center

/// 한 장면의 토스트. 창은 마지막 토스트가 다 빠져나간 뒤에 닫는다.
@MainActor @Observable
final class ToastCenter {
    var toasts: [ToastValue] = []
    private(set) var isPresented = false

    func present(_ toast: ToastValue) {
        isPresented = true
        toasts.append(toast)
        UIAccessibility.post(
            notification: .announcement,
            argument: [toast.title, toast.message].compactMap(\.self).joined(separator: ", "),
        )
    }

    func dismiss(_ id: ToastValue.ID) {
        withAnimation(.strongOut) {
            toasts.removeAll { $0.id == id }
        }
    }

    func didFinish() {
        if toasts.isEmpty {
            isPresented = false
        }
    }
}

// MARK: - Install Toasts Modifier

private struct InstallToastsModifier: ViewModifier {
    @State private var center = ToastCenter()

    func body(content: Content) -> some View {
        content
            .environment(\.presentToast, PresentToastAction(center: center))
            .background {
                ToastWindowBridge(center: center, isPresented: center.isPresented)
                    .allowsHitTesting(false)
            }
    }
}

/// 장면 뿌리에 깔려 그 장면의 `PassthroughWindow`를 띄우고 닫는다.
private struct ToastWindowBridge: UIViewRepresentable {
    let center: ToastCenter
    let isPresented: Bool

    func makeUIView(context _: Context) -> ToastWindowAnchor {
        ToastWindowAnchor(center: center)
    }

    func updateUIView(_ anchor: ToastWindowAnchor, context: Context) {
        anchor.update(isPresented: isPresented, environment: context.environment)
    }
}

/// 떠 있는 창은 SwiftUI 계층 밖이라 환경(색 구성·글자 크기·테마)을 직접 넘긴다.
private struct ToastWindowRoot: View {
    let center: ToastCenter
    let environment: EnvironmentValues
    let onHittableFramesChange: ([CGRect]) -> Void

    var body: some View {
        @Bindable var center = center
        ToastOverlayView(
            toasts: $center.toasts,
            onFinish: { center.didFinish() },
        )
        .onPreferenceChange(HittableFramesPreferenceKey.self) { onHittableFramesChange($0) }
        .environment(\.self, environment)
    }
}

private final class ToastWindowAnchor: UIView {
    private let toastCenter: ToastCenter
    private var isPresented = false
    private var environment = EnvironmentValues()
    private var overlayWindow: PassthroughWindow?
    private var hostingController: StatusBarForwardingHostingController<ToastWindowRoot>?

    init(center: ToastCenter) {
        self.toastCenter = center
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let scene = window?.windowScene {
            if overlayWindow?.windowScene !== scene {
                tearDown()
                overlayWindow = PassthroughWindow(windowScene: scene)
            }
            updateWindow()
        } else {
            tearDown()
        }
    }

    func update(isPresented: Bool, environment: EnvironmentValues) {
        self.isPresented = isPresented
        self.environment = environment
        updateWindow()
    }

    private func updateWindow() {
        guard let overlayWindow else { return }
        guard isPresented else {
            overlayWindow.isHidden = true
            overlayWindow.rootViewController = nil
            hostingController = nil
            return
        }
        let root = ToastWindowRoot(center: toastCenter, environment: environment) {
            [weak overlayWindow] frames in
            overlayWindow?.hittableFrames = frames
        }
        if let hostingController {
            hostingController.rootView = root
        } else {
            let controller = StatusBarForwardingHostingController(rootView: root)
            controller.view.backgroundColor = .clear
            overlayWindow.rootViewController = controller
            hostingController = controller
        }
        hostingController?.sourceWindow = window
        // 상태 표시줄 글자색이 앱 창과 같도록 (`.preferredColorScheme`은 앱 창에 걸린다).
        overlayWindow.overrideUserInterfaceStyle = window?.overrideUserInterfaceStyle
            ?? .unspecified
        overlayWindow.isHidden = false
        hostingController?.setNeedsStatusBarAppearanceUpdate()
    }

    private func tearDown() {
        overlayWindow?.isHidden = true
        overlayWindow?.rootViewController = nil
        overlayWindow = nil
        hostingController = nil
    }
}

// MARK: - Toast Overlay View

private struct ToastOverlayView: View {
    @Binding var toasts: [ToastValue]
    let onFinish: () -> Void
    /// 화면에 그리는 토스트. `toasts`를 애니메이션으로 따라가서 퇴장이 끝나는 시점을 안다.
    @State private var shown: [ToastValue] = []

    var body: some View {
        ZStack(alignment: .top) {
            // 배경: 터치 통과
            Color.clear
                .ignoresSafeArea()

            // Toast 스택
            ZStack(alignment: .top) {
                ForEach(shown) { item in
                    let indexFromTop = toasts.firstIndex(where: { $0.id == item.id })
                        .map { toasts.count - 1 - $0 }

                    SingleToastView(
                        toast: item,
                        indexFromTop: indexFromTop,
                        totalCount: toasts.count,
                        onDismiss: { dismissToast(item.id) },
                    )
                    .hittable()
                    // 화면 끝 너머로 빠지면서 옅어진다. 잘리는 곳 없이 끝까지 보인다.
                    .transition(
                        .offset(y: -120)
                            .combined(with: .scale(0.8, anchor: .top))
                            .combined(with: .opacity),
                    )
                    // 토스트가 사라지면 함께 취소된다.
                    .task { await autoDismiss(item) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
        }
        .onAppear(perform: sync)
        .onChange(of: toasts, sync)
    }

    private func sync() {
        withAnimation(.strongOut) {
            shown = toasts
        } completion: {
            if toasts.isEmpty {
                onFinish()
            }
        }
    }

    private func autoDismiss(_ toast: ToastValue) async {
        guard let duration = toast.duration,
              await (try? Task.sleep(for: .seconds(duration))) != nil
        else { return }
        dismissToast(toast.id)
    }

    private func dismissToast(_ id: UUID) {
        withAnimation(.strongOut) {
            toasts.removeAll { $0.id == id }
        }
    }
}

// MARK: - Single Toast View

private struct SingleToastView: View {
    let toast: ToastValue
    let indexFromTop: Int?
    let totalCount: Int
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    /// 닫힐 때 zIndex가 역전되는 현상을 막기 위해 사용
    @State private var isDismissing = false

    private var isTopmost: Bool {
        indexFromTop == 0
    }

    private var clampedIndex: CGFloat {
        CGFloat(min(indexFromTop ?? 0, 3))
    }

    private var scale: CGFloat {
        1.0 - clampedIndex * 0.05
    }

    private var yOffset: CGFloat {
        clampedIndex * 8 + dragOffset
    }

    private var opacity: CGFloat {
        if (indexFromTop ?? 0) > 3 {
            return 0
        }
        return max(1.0 - clampedIndex * 0.15, 0.5)
    }

    var body: some View {
        content
            .scaleEffect(scale)
            .offset(y: yOffset)
            .opacity(opacity)
            .zIndex(isDismissing ? 999 : Double(-(indexFromTop ?? 0)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard isTopmost else { return }
                        let height = value.translation.height
                        // 닫는 쪽(위)은 손가락을 그대로 따라가고, 아래로는 sqrt로 끈끈하게 버틴다.
                        dragOffset = height < 0
                            ? height
                            : (height < 0 ? -1 : 1) * sqrt(abs(height)) * 3
                    }
                    .onEnded { value in
                        if isTopmost,
                           -value.translation.height > 50 || -value.velocity.height > 300
                        {
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

    @ViewBuilder private var content: some View {
        if toast.isCompact {
            HStack(spacing: Space.s + 2) {
                ToastBadge(toast: toast)
                Text(toast.title)
                    .textRole(.headline)
                    .foregroundStyle(Palette.ink1)
                    .lineLimit(1)
            }
            .padding(.leading, Space.s)
            .padding(.trailing, Space.l + 2)
            .padding(.vertical, Space.s)
            .background(Palette.raised, in: .capsule)
            .floatingShadow()
        } else {
            HStack(spacing: Space.m) {
                ToastBadge(toast: toast)

                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(toast.title)
                        .textRole(.headline)
                        .foregroundStyle(Palette.ink1)
                    if let message = toast.message {
                        Text(message)
                            .textRole(.footnote)
                            .foregroundStyle(Palette.ink3)
                    }
                }

                Spacer(minLength: 0)

                if toast.showCloseButton {
                    Button {
                        dismiss()
                    } label: {
                        IconView(.close, size: 11)
                            .foregroundStyle(Palette.ink3)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Palette.fill3))
                            .contentShape(.rect.inset(by: -10))
                    }
                    .buttonStyle(.pressable)
                    .accessibilityLabel(Text(String(localized: "Close", bundle: .module)))
                }
            }
            .padding(.leading, Space.m)
            .padding(.trailing, Space.l)
            .padding(.vertical, Space.m)
            .frame(maxWidth: 400)
            .background(Palette.raised, in: .rect(cornerRadius: Radius.card, style: .continuous))
            .floatingShadow()
        }
    }
}

// MARK: - Toast Badge

/// 종류 색으로 채운 원 + 아이콘. 체크박스·톤 칩처럼 색은 상태에만 쓴다.
private struct ToastBadge: View {
    let toast: ToastValue

    private var glyph: Icon {
        if let icon = toast.icon {
            return icon
        }
        return switch toast.type {
        case .default: .bell
        case .success: .check
        case .warning: .exclamation
        case .danger: .close
        }
    }

    private var fill: Color {
        switch toast.type {
        case .default: Palette.fill3
        case .success: Palette.theme
        case .warning: Palette.yellow
        case .danger: Palette.red
        }
    }

    private var ink: Color {
        switch toast.type {
        case .default: Palette.ink1
        case .success: Palette.onTheme
        // 노랑은 밝아서 테마와 상관없이 검정 글리프
        case .warning: .black
        case .danger: .white
        }
    }

    var body: some View {
        Group {
            if toast.icon == nil, let systemImage = toast.systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
            } else {
                IconView(glyph, size: 16)
            }
        }
        .foregroundStyle(ink)
        .frame(width: 30, height: 30)
        .background(Circle().fill(fill))
        .accessibilityHidden(true)
    }
}

extension View {
    /// 떠 있는 것의 얕은 그림자. 화면 어디에 떠도 경계가 보일 만큼만.
    fileprivate func floatingShadow() -> some View {
        shadow(color: Palette.popShadow.opacity(0.8), radius: 14, y: 4)
    }
}

// MARK: - View Extension

extension View {
    /// Shows toasts presented with the `presentToast` environment action below this view.
    ///
    /// Call it once on the scene's root view. Toasts float in a window above everything in the
    /// scene — navigation bars, sheets and full-screen covers — at the top of the screen,
    /// and stay when the screen that presented them goes away. Touches outside a toast pass
    /// through.
    public func installToasts() -> some View {
        modifier(InstallToastsModifier())
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Toast") {
        ToastPreview()
            .installToasts()
    }

    #Preview("Toast Styles") {
        ToastStylesPreview()
    }

    private struct ToastStylesPreview: View {
        private let samples: [ToastValue] = [
            ToastValue(title: "Copied to clipboard", type: .success),
            ToastValue(
                title: "Storage almost full",
                message: "Free up space to keep syncing.",
                type: .warning,
            ),
            ToastValue(
                title: "Connection lost",
                message: "Retrying…",
                type: .danger,
                duration: nil,
            ),
            ToastValue(title: "3 apps added"),
            ToastValue(title: "Tap an app to remove it", icon: .pencil),
        ]

        var body: some View {
            VStack(spacing: Space.l) {
                ForEach(samples) { toast in
                    SingleToastView(
                        toast: toast,
                        indexFromTop: 0,
                        totalCount: 1,
                        onDismiss: {},
                    )
                }
            }
            .padding(Space.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenBackground()
        }
    }

    private struct ToastPreview: View {
        @Environment(\.presentToast) private var presentToast
        @State private var count = 0

        var body: some View {
            ZStack {
                ScreenBackground()

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

                        count += 1
                        presentToast(ToastValue(
                            title: "Toast \(count)",
                            message: messages[randomIndex],
                            type: types[randomIndex],
                            duration: 5.0,
                        ))
                    }
                    .buttonStyle(.primary(.regular))

                    Button("Compact") {
                        presentToast(ToastValue(title: "Copied to clipboard", type: .success))
                    }
                    .buttonStyle(.secondary(.small))
                }
                .padding()
            }
        }
    }
#endif
