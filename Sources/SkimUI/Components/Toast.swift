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

// MARK: - Toast Position

/// The screen edge toasts appear at.
public enum ToastPosition: Sendable {
    /// Above the tab bar, the home indicator and the keyboard.
    case bottom
    /// Below the status bar.
    case top
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
    let position: ToastPosition
    @State private var center = ToastCenter()

    func body(content: Content) -> some View {
        content
            .environment(\.presentToast, PresentToastAction(center: center))
            .background {
                ToastWindowBridge(
                    center: center,
                    position: position,
                    isPresented: center.isPresented,
                )
                .allowsHitTesting(false)
            }
    }
}

/// 장면 뿌리에 깔려 그 장면의 `PassthroughWindow`를 띄우고 닫는다.
private struct ToastWindowBridge: UIViewRepresentable {
    let center: ToastCenter
    let position: ToastPosition
    let isPresented: Bool

    func makeUIView(context _: Context) -> ToastWindowAnchor {
        ToastWindowAnchor(center: center)
    }

    func updateUIView(_ anchor: ToastWindowAnchor, context: Context) {
        anchor.update(
            position: position,
            isPresented: isPresented,
            environment: context.environment,
        )
    }
}

/// 떠 있는 창은 SwiftUI 계층 밖이라 환경(색 구성·글자 크기·테마)을 직접 넘긴다.
private struct ToastWindowRoot: View {
    let center: ToastCenter
    let position: ToastPosition
    let environment: EnvironmentValues
    let bottomObstruction: () -> CGFloat
    let onHittableFramesChange: ([CGRect]) -> Void

    var body: some View {
        @Bindable var center = center
        ToastOverlayView(
            toasts: $center.toasts,
            position: position,
            bottomObstruction: bottomObstruction,
            onFinish: { center.didFinish() },
        )
        .onPreferenceChange(HittableFramesPreferenceKey.self) { onHittableFramesChange($0) }
        .environment(\.self, environment)
    }
}

private final class ToastWindowAnchor: UIView {
    private let toastCenter: ToastCenter
    private var position = ToastPosition.bottom
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

    func update(position: ToastPosition, isPresented: Bool, environment: EnvironmentValues) {
        self.position = position
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
        let root = ToastWindowRoot(
            center: toastCenter,
            position: position,
            environment: environment,
            bottomObstruction: { [weak self] in self?.bottomObstruction() ?? 0 },
            onHittableFramesChange: { [weak overlayWindow] frames in
                overlayWindow?.hittableFrames = frames
            },
        )
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

    /// 앱 창 맨 앞 화면에 보이는 탭 바가 화면 아래에서 차지하는 높이. 없으면 0.
    /// 떠 있는 창은 앱의 안전 영역을 모르므로 직접 찾는다.
    private func bottomObstruction() -> CGFloat {
        guard let window, var front = window.rootViewController else { return 0 }
        while let presented = front.presentedViewController, !presented.isBeingDismissed {
            front = presented
        }
        guard let tabBar = Self.visibleTabBar(in: front.view) else { return 0 }
        let top = tabBar.convert(tabBar.bounds, to: window).minY
        return max(window.bounds.height - top, 0)
    }

    private static func visibleTabBar(in view: UIView) -> UITabBar? {
        guard !view.isHidden, view.alpha > 0.01 else { return nil }
        if let tabBar = view as? UITabBar {
            return tabBar
        }
        for subview in view.subviews.reversed() {
            if let tabBar = visibleTabBar(in: subview) {
                return tabBar
            }
        }
        return nil
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
    let position: ToastPosition
    let bottomObstruction: () -> CGFloat
    let onFinish: () -> Void
    /// 화면에 그리는 토스트. `toasts`를 애니메이션으로 따라가서 퇴장이 끝나는 시점을 안다.
    @State private var shown: [ToastValue] = []
    /// 앱 창의 탭 바 높이 (화면 아래에서). 토스트가 바뀔 때마다 다시 잰다.
    @State private var obstruction: CGFloat = 0

    private var isBottom: Bool {
        position == .bottom
    }

    var body: some View {
        // 안전 영역(아래는 키보드 포함)과 탭 바 중 높은 쪽 위에 놓는다.
        GeometryReader { proxy in
            stack
                .padding(.top, proxy.safeAreaInsets.top + 8)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, obstruction) + 8)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: isBottom ? .bottom : .top,
                )
                .ignoresSafeArea()
        }
        .onAppear(perform: sync)
        .onChange(of: toasts, sync)
    }

    private var stack: some View {
        ZStack(alignment: isBottom ? .bottom : .top) {
            ForEach(shown) { item in
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
                // 화면 끝 너머로 빠지면서 옅어진다. 잘리는 곳 없이 끝까지 보인다.
                .transition(
                    .offset(y: isBottom ? 120 : -120)
                        .combined(with: .scale(0.8, anchor: isBottom ? .bottom : .top))
                        .combined(with: .opacity),
                )
                // 토스트가 사라지면 함께 취소된다.
                .task { await autoDismiss(item) }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }

    private func sync() {
        withAnimation(.strongOut) {
            obstruction = isBottom ? bottomObstruction() : 0
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
    let isBottom: Bool
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
        (isBottom ? -1 : 1) * clampedIndex * 8 + dragOffset
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
                        // 닫는 쪽(화면 끝)은 손가락을 그대로 따라가고, 반대쪽은 sqrt로 끈끈하게 버틴다.
                        dragOffset = towardDismiss(height) > 0
                            ? height
                            : (height < 0 ? -1 : 1) * sqrt(abs(height)) * 3
                    }
                    .onEnded { value in
                        if isTopmost,
                           towardDismiss(value.translation.height) > 50
                           || towardDismiss(value.velocity.height) > 300
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

    /// 세로 이동을 닫는 방향 기준으로 바꾼다 (양수 = 닫는 쪽).
    private func towardDismiss(_ height: CGFloat) -> CGFloat {
        isBottom ? height : -height
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
    /// scene — navigation bars, sheets and full-screen covers — and stay when the screen that
    /// presented them goes away. Touches outside a toast pass through.
    ///
    /// - Parameter position: `.bottom` (default) sits above the tab bar, the home indicator
    ///   and the keyboard. `.top` sits below the status bar.
    public func installToasts(position: ToastPosition = .bottom) -> some View {
        modifier(InstallToastsModifier(position: position))
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
                        isBottom: false,
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
