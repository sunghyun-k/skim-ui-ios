// MARK: - NonAnimatedFullScreenCover

import Combine
import SwiftUI
import UIKit

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
    func hittable() -> some View {
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
    func nonAnimatedFullScreenCover(
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
}

// MARK: - Bool-based Modifier

@MainActor
private final class Coordinator: ObservableObject {
    let overlay: PassthroughOverlayView = .init()
}

private struct NonAnimatedFullScreenCoverModifier<C: View>: ViewModifier {
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?
    var overlayContent: () -> C

    @State private var internalIsPresented = false
    @StateObject private var coordinator = Coordinator()

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, initial: true) { _, newValue in
                setPresented(newValue)
            }
            .fullScreenCover(isPresented: $internalIsPresented, onDismiss: onDismiss) {
                overlayContent()
                    .onPreferenceChange(HittableFramesPreferenceKey.self) { frames in
                        coordinator.overlay.hittableFrames = frames
                    }
                    .presentationBackground(.clear)
                    .background {
                        PresentationFinder { presentationController in
                            guard let hostingView = presentationController.presentedView,
                                  let containerView = hostingView.superview,
                                  !containerView.subviews
                                  .contains(where: { $0 is PassthroughOverlayView })
                            else { return }

                            let presentingView = presentationController.presentingViewController
                                .view
                            coordinator.overlay.presentingView = presentingView
                            coordinator.overlay.hostingView = hostingView
                            coordinator.overlay.frame = containerView.bounds
                            containerView.addSubview(coordinator.overlay)
                        }
                    }
            }
    }

    private func setPresented(_ value: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            internalIsPresented = value
        }
    }
}

// MARK: - Presentation Finder

/// 커버 안에 깔려 창에 붙는 순간, 응답자 사슬을 따라 커버를 띄운 프레젠테이션 컨트롤러를 찾는다.
private struct PresentationFinder: UIViewRepresentable {
    let onFind: (UIPresentationController) -> Void

    func makeUIView(context _: Context) -> FinderView {
        let view = FinderView()
        view.onFind = onFind
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: FinderView, context _: Context) {
        view.onFind = onFind
    }

    final class FinderView: UIView {
        var onFind: ((UIPresentationController) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            find()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            find()
        }

        private func find() {
            guard window != nil,
                  var controller = sequence(first: self as UIResponder, next: \.next)
                  .lazy.compactMap({ $0 as? UIViewController }).first
            else { return }
            while let parent = controller.parent {
                controller = parent
            }
            guard controller.presentingViewController != nil,
                  let presentationController = controller.presentationController,
                  presentationController.containerView != nil
            else { return }
            onFind?(presentationController)
        }
    }
}

// MARK: - Passthrough Overlay View

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
