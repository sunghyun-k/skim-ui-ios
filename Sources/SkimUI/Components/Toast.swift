import SwiftUI

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

// MARK: - Toasts Modifier

private struct ToastsModifier: ViewModifier {
    @Binding var toasts: [ToastValue]
    let alignment: Alignment
    @State private var presentCover = false
    /// 붙인 뷰의 안전 영역 안쪽 (화면 좌표). 탭 바·툴바·`.bottomBar`·키보드가 저절로 빠진다.
    @State private var safeFrame: CGRect?

    func body(content: Content) -> some View {
        content
            // 뷰의 프레임은 이미 안전 영역 안쪽이다 (`safeAreaInsets`는 그 바깥으로 뻗을 수 있는 양).
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { safeFrame = $0 }
            .onChange(of: toasts.isEmpty, initial: true) { _, isEmpty in
                if !isEmpty {
                    presentCover = true
                }
            }
            // 커버는 마지막 토스트가 다 빠져나간 뒤 오버레이가 닫는다.
            .nonAnimatedFullScreenCover(isPresented: $presentCover) {
                ToastOverlayView(
                    toasts: $toasts,
                    alignment: alignment,
                    safeFrame: safeFrame,
                    onFinish: { presentCover = false },
                )
            }
    }
}

// MARK: - Toast Overlay View

private struct ToastOverlayView: View {
    @Binding var toasts: [ToastValue]
    let alignment: Alignment
    let safeFrame: CGRect?
    let onFinish: () -> Void
    /// 화면에 그리는 토스트. `toasts`를 애니메이션으로 따라가서 퇴장이 끝나는 시점을 안다.
    @State private var shown: [ToastValue] = []

    private var isBottom: Bool {
        alignment.vertical == .bottom
    }

    private var transitionOffset: CGFloat {
        isBottom ? 150 : -150
    }

    var body: some View {
        ZStack(alignment: alignment) {
            // 배경: 터치 통과
            Color.clear
                .ignoresSafeArea()

            // Toast 스택
            ZStack(alignment: alignment) {
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
                    .transition(.offset(y: transitionOffset))
                    // 토스트가 사라지면 함께 취소된다.
                    .task { await autoDismiss(item) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, isBottom ? 0 : 8)
            .padding(.bottom, isBottom ? 8 : 0)
            .frame(maxWidth: .infinity, alignment: alignment)
            .modifier(SafeFramePlacement(safeFrame: safeFrame, alignment: alignment))
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

/// 커버는 기기 안전 영역만 안다. 붙인 뷰의 안전 영역 안쪽에 맞춰 놓는다.
private struct SafeFramePlacement: ViewModifier {
    let safeFrame: CGRect?
    let alignment: Alignment

    func body(content: Content) -> some View {
        if let safeFrame {
            GeometryReader { _ in
                content
                    .frame(width: safeFrame.width, height: safeFrame.height, alignment: alignment)
                    .offset(x: safeFrame.minX, y: safeFrame.minY)
            }
            .ignoresSafeArea()
        } else {
            content
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
        let baseOffset = clampedIndex * 8
        return isBottom ? -baseOffset + dragOffset : baseOffset + dragOffset
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
                        // 닫는 쪽은 손가락을 그대로 따라가고, 반대쪽은 sqrt로 끈끈하게 버틴다.
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
    /// Displays toast notifications from a binding array.
    ///
    /// Toasts are displayed when added to the array and dismissed when removed.
    /// Users can also dismiss toasts by swiping (up for top alignment, down for bottom).
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
        @State private var toasts: [ToastValue] = []

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

                        toasts.append(ToastValue(
                            title: "Toast \(toasts.count + 1)",
                            message: messages[randomIndex],
                            type: types[randomIndex],
                            duration: 5.0,
                        ))
                    }
                    .buttonStyle(.primary(.regular))

                    Button("Clear All") {
                        toasts.removeAll()
                    }
                    .buttonStyle(.secondary(.small))

                    Text("Active toasts: \(toasts.count)")
                        .textRole(.caption)
                        .foregroundStyle(Palette.ink3)
                }
                .padding()
            }
            .toasts($toasts, alignment: .top)
        }
    }
#endif
