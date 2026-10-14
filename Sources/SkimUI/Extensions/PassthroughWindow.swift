// MARK: - PassthroughWindow

import SwiftUI
import UIKit

/// 앱 창 위에 떠서 `.hittable()`로 표시한 곳만 터치를 받고, 나머지는 아래 창으로 흘려보낸다.
final class PassthroughWindow: UIWindow {
    /// 창 좌표. `.hittable()`이 모은 프레임.
    var hittableFrames: [CGRect] = []

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        // 시트·키보드 위. 시스템 알림 창보다는 아래.
        windowLevel = .alert - 1
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootView = rootViewController?.view,
              let hitView = super.hitTest(point, with: event)
        else { return nil }
        // 호스팅 뷰가 그리는 SwiftUI 내용은 뷰 하나라 프레임으로 가린다.
        if hitView === rootView, !hittableFrames.contains(where: { $0.contains(point) }) {
            return nil
        }
        return hitView
    }
}

// MARK: - Hittable

/// `.hittable()`이 모으는 프레임 (global 좌표 = 창 좌표).
struct HittableFramesPreferenceKey: PreferenceKey {
    static let defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    /// `PassthroughWindow` 안에서 터치를 받을 곳으로 표시한다. 나머지는 아래 창으로 간다.
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

// MARK: - Status Bar

/// 상태 표시줄은 맨 위 창의 루트 컨트롤러가 정한다. 떠 있는 창이 상태 표시줄을 바꾸지 않도록
/// 아래 앱 창에서 상태 표시줄을 정하는 컨트롤러의 값을 그대로 돌려준다.
final class StatusBarForwardingHostingController<Content: View>: UIHostingController<Content> {
    weak var sourceWindow: UIWindow?

    override var prefersStatusBarHidden: Bool {
        source { $0.childForStatusBarHidden }?.prefersStatusBarHidden
            ?? super.prefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        source { $0.childForStatusBarStyle }?.preferredStatusBarStyle
            ?? super.preferredStatusBarStyle
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        source { $0.childForStatusBarHidden }?.preferredStatusBarUpdateAnimation
            ?? super.preferredStatusBarUpdateAnimation
    }

    /// UIKit과 같은 규칙: 전체 화면으로 띄웠거나 상태 표시줄을 가져간 컨트롤러까지 올라간 뒤 자식을 따라간다.
    private func source(child: (UIViewController) -> UIViewController?) -> UIViewController? {
        guard var controller = sourceWindow?.rootViewController else { return nil }
        while let presented = controller.presentedViewController,
              !presented.isBeingDismissed,
              presented.modalPresentationStyle == .fullScreen
              || presented.modalPresentationCapturesStatusBarAppearance
        {
            controller = presented
        }
        while let next = child(controller), next !== controller {
            controller = next
        }
        return controller
    }
}
