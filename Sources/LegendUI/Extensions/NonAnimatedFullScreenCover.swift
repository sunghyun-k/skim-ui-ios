// MARK: - NonAnimatedFullScreenCover

import Combine
import SwiftUI

#if canImport(UIKit)
    @_spi(Advanced) import SwiftUIIntrospect
#endif

// MARK: - Hittable Preference

private struct HittableFramesPreferenceKey: PreferenceKey {
    static let defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    /// Marks this view as a touch-hittable region within a non-animated full-screen cover.
    ///
    /// When used inside `nonAnimatedFullScreenCover`, touches within this area are handled
    /// by the cover's hosting view. Touches outside hittable areas are forwarded to the
    /// presenting view beneath the cover.
    ///
    /// - Returns: A view that registers its frame as a hittable region.
    public func hittable() -> some View {
        background {
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: HittableFramesPreferenceKey.self,
                        value: [geometry.frame(in: .global)],
                    )
            }
        }
    }
}

extension View {
    /// Presents a non-animated full-screen cover.
    ///
    /// The cover is presented without any transition animation. On iOS, touches outside
    /// areas marked with `.hittable()` are forwarded to the presenting view.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the cover is presented.
    ///   - onDismiss: An optional closure called when the cover is dismissed.
    ///   - content: A view builder that creates the cover content.
    /// - Returns: A view with the full-screen cover capability attached.
    public func nonAnimatedFullScreenCover(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> some View,
    ) -> some View {
        modifier(NonAnimatedFullScreenCoverModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            overlayContent: content,
        ))
    }

    /// Presents a non-animated full-screen cover driven by an optional item.
    ///
    /// The cover is presented when the item is non-nil and dismissed when it becomes nil.
    /// No transition animation is applied. On iOS, touches outside areas marked with
    /// `.hittable()` are forwarded to the presenting view.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional identifiable item that drives presentation.
    ///   - onDismiss: An optional closure called when the cover is dismissed.
    ///   - content: A view builder that creates the cover content using the item.
    /// - Returns: A view with the full-screen cover capability attached.
    public func nonAnimatedFullScreenCover<Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> some View,
    ) -> some View {
        modifier(NonAnimatedFullScreenCoverItemModifier(
            item: item,
            onDismiss: onDismiss,
            overlayContent: content,
        ))
    }
}

// MARK: - Bool-based Modifier

#if canImport(UIKit)
    @MainActor
    private final class Coordinator: ObservableObject {
        let overlay: PassthroughOverlayView = .init()
    }
#endif

private struct NonAnimatedFullScreenCoverModifier<C: View>: ViewModifier {
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?
    var overlayContent: () -> C

    @State private var internalIsPresented = false
    #if os(iOS)
        @StateObject private var coordinator = Coordinator()
    #endif

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                setPresented(newValue)
            }
            .onAppear {
                if isPresented {
                    setPresented(true)
                }
            }
        #if os(iOS)
            .fullScreenCover(isPresented: $internalIsPresented, onDismiss: onDismiss) {
                overlayContent()
                    .onPreferenceChange(HittableFramesPreferenceKey.self) { frames in
                        coordinator.overlay.hittableFrames = frames
                    }
                    .presentationBackground(.clear)
                    .introspect(.fullScreenCover, on: .iOS(.v17...)) { presentationController in
                        guard let hostingView = presentationController.presentedView,
                              let containerView = hostingView.superview,
                              !containerView.subviews
                              .contains(where: { $0 is PassthroughOverlayView })
                        else { return }

                        let presentingView = presentationController.presentingViewController.view
                        coordinator.overlay.presentingView = presentingView
                        coordinator.overlay.hostingView = hostingView
                        coordinator.overlay.frame = containerView.bounds
                        containerView.addSubview(coordinator.overlay)
                    }
            }
        #else
            .overlay {
                    if internalIsPresented {
                        overlayContent()
                    }
                }
                .onChange(of: internalIsPresented) { _, newValue in
                    if !newValue {
                        onDismiss?()
                    }
                }
        #endif
    }

    private func setPresented(_ value: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            internalIsPresented = value
        }
    }
}

// MARK: - Item-based Modifier

private struct NonAnimatedFullScreenCoverItemModifier<Item: Identifiable, C: View>: ViewModifier {
    @Binding var item: Item?
    var onDismiss: (() -> Void)?
    var overlayContent: (Item) -> C

    @State private var internalItem: Item?
    #if os(iOS)
        @StateObject private var coordinator = Coordinator()
    #endif

    func body(content: Content) -> some View {
        content
            .onChange(of: item?.id) { _, _ in
                setItem(item)
            }
            .onAppear {
                if item != nil {
                    setItem(item)
                }
            }
        #if os(iOS)
            .fullScreenCover(item: $internalItem, onDismiss: onDismiss) { item in
                overlayContent(item)
                    .onPreferenceChange(HittableFramesPreferenceKey.self) { frames in
                        coordinator.overlay.hittableFrames = frames
                    }
                    .presentationBackground(.clear)
                    .introspect(.fullScreenCover, on: .iOS(.v17...)) { presentationController in
                        guard let hostingView = presentationController.presentedView,
                              let containerView = hostingView.superview,
                              !containerView.subviews
                              .contains(where: { $0 is PassthroughOverlayView })
                        else { return }

                        let presentingView = presentationController.presentingViewController.view
                        coordinator.overlay.presentingView = presentingView
                        coordinator.overlay.hostingView = hostingView
                        coordinator.overlay.frame = containerView.bounds
                        containerView.addSubview(coordinator.overlay)
                    }
            }
        #else
            .overlay {
                    if let internalItem {
                        overlayContent(internalItem)
                    }
                }
                .onChange(of: internalItem?.id) { oldValue, newValue in
                    if oldValue != nil, newValue == nil {
                        onDismiss?()
                    }
                }
        #endif
    }

    private func setItem(_ value: Item?) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            internalItem = value
        }
    }
}

// MARK: - Passthrough Overlay View

#if canImport(UIKit)
    /// A UIView that forwards touches to the presenting view or the hosting view based on hittable
    /// regions.
    ///
    /// This view is placed over the full-screen cover's container view to intercept all touches.
    /// Touches within `hittableFrames` are forwarded to `hostingView` (the cover content),
    /// while touches outside these regions are passed through to `presentingView`.
    final class PassthroughOverlayView: UIView {
        weak var presentingView: UIView?
        weak var hostingView: UIView?
        var hittableFrames: [CGRect] = []

        init() {
            super.init(frame: .zero)
            backgroundColor = .clear
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            // global 좌표로 변환
            let globalPoint = convert(point, to: nil)

            // hittable 영역 중 하나에 포함되면 hostingView로 전달
            for frame in hittableFrames {
                if frame.contains(globalPoint), let hostingView {
                    let convertedPoint = convert(point, to: hostingView)
                    return hostingView.hitTest(convertedPoint, with: event)
                }
            }

            // 나머지는 presentingView로 패스스루
            guard let presentingView else {
                return nil
            }

            let convertedPoint = convert(point, to: presentingView)
            return presentingView.hitTest(convertedPoint, with: event)
        }
    }
#endif

// MARK: - Preview

#Preview {
    NonAnimatedFullScreenCoverPreview()
}

private struct NonAnimatedFullScreenCoverPreview: View {
    @State private var showCover = false

    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 50) {
                Button("Show Full Screen Cover") {
                    showCover = true
                }
                Button("Hide Full Screen Cover") {
                    showCover = false
                }
            }
            .buttonStyle(.borderedProminent)
            .nonAnimatedFullScreenCover(isPresented: $showCover) {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("Non-Animated Full Screen Cover")
                            .font(.title)
                            .foregroundStyle(.white)

                        Button("Close") {
                            showCover = false
                        }
                        .buttonStyle(.bordered)
                        .tint(.white)
                    }
                    .hittable()
                }
            }
        }
    }
}
