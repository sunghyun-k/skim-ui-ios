import SwiftUI
#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

/// 뷰의 좌우 변에서, 뷰를 잘라 보이는 가장 가까운 상위 뷰(세로 스크롤 뷰, 시트, iPad 분할 열, 없으면 창)의 안전 영역 가장자리까지
/// 거리(화면 기준 왼쪽·오른쪽). 부모가 어떤 여백으로 띄웠든 실제로 잰다.
///
/// SwiftUI 는 안쪽 뷰에 보이는 영역의 크기와 안전 영역을 알려 주지 않아 플랫폼 뷰로 잰다. 창을 기준으로 잡으면 시트나 분할 열 안에서
/// 잘린 바깥까지 넘쳐 마지막 칩을 끝까지 밀어 볼 수 없다. 크기가 그대로인 채 가로 자리만 옮겨도 다시 재도록 SwiftUI 좌표를 함께 넘긴다.
struct SafeEdgeDistance: Equatable {
    var left: CGFloat
    var right: CGFloat
}

extension View {
    func onSafeEdgeDistanceChange(_ action: @escaping (SafeEdgeDistance) -> Void) -> some View {
        modifier(SafeEdgeDistanceReader(action: action))
    }
}

private struct SafeEdgeDistanceReader: ViewModifier {
    let action: (SafeEdgeDistance) -> Void
    /// 가로 위치만 본다(세로로 스크롤할 때마다 다시 그리지 않게).
    @State private var span: [CGFloat] = []

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: [CGFloat].self) { proxy in
                let frame = proxy.frame(in: .global)
                return [frame.minX, frame.maxX]
            } action: { span = $0 }
            .background(SafeEdgeProbe(span: span, action: action).allowsHitTesting(false))
    }
}

#if canImport(UIKit)
    private struct SafeEdgeProbe: UIViewRepresentable {
        let span: [CGFloat]
        let action: (SafeEdgeDistance) -> Void

        func makeUIView(context _: Context) -> ProbeView {
            ProbeView()
        }

        func updateUIView(_ view: ProbeView, context _: Context) {
            view.action = action
            view.report()
        }

        final class ProbeView: UIView {
            var action: ((SafeEdgeDistance) -> Void)?
            private var last: SafeEdgeDistance?

            override func didMoveToWindow() {
                super.didMoveToWindow()
                report()
            }

            override func layoutSubviews() {
                super.layoutSubviews()
                report()
            }

            override func safeAreaInsetsDidChange() {
                super.safeAreaInsetsDidChange()
                report()
            }

            func report() {
                guard let window else { return }
                var clip: UIView = window
                var ancestor = superview
                while let view = ancestor, view !== window {
                    if view.clipsToBounds {
                        clip = view
                        break
                    }
                    ancestor = view.superview
                }
                let rect = convert(bounds, to: clip)
                let visible = clip.bounds
                let safe = clip.safeAreaInsets
                let distance = SafeEdgeDistance(
                    left: max(0, rect.minX - visible.minX - safe.left),
                    right: max(0, visible.maxX - safe.right - rect.maxX),
                )
                guard distance != last else { return }
                last = distance
                // 레이아웃 중에 SwiftUI 상태를 바꾸지 않는다.
                DispatchQueue.main.async { [action] in action?(distance) }
            }
        }
    }
#else
    private struct SafeEdgeProbe: NSViewRepresentable {
        let span: [CGFloat]
        let action: (SafeEdgeDistance) -> Void

        func makeNSView(context _: Context) -> ProbeView {
            ProbeView()
        }

        func updateNSView(_ view: ProbeView, context _: Context) {
            view.action = action
            view.report()
        }

        final class ProbeView: NSView {
            var action: ((SafeEdgeDistance) -> Void)?
            private var last: SafeEdgeDistance?

            override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                report()
            }

            override func layout() {
                super.layout()
                report()
            }

            func report() {
                guard let root = window?.contentView else { return }
                let clip: NSView = enclosingScrollView?.contentView ?? root
                let rect = convert(bounds, to: clip)
                let visible = clip.bounds
                let safe = clip.safeAreaInsets
                let distance = SafeEdgeDistance(
                    left: max(0, rect.minX - visible.minX - safe.left),
                    right: max(0, visible.maxX - safe.right - rect.maxX),
                )
                guard distance != last else { return }
                last = distance
                DispatchQueue.main.async { [action] in action?(distance) }
            }
        }
    }
#endif
