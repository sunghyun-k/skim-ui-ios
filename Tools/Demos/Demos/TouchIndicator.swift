import UIKit

/// 손가락 자리에 반투명 원을 그린다. 시뮬레이터의 "Show Single Touches"는 녹화에 담기지 않아서 앱이 직접 그린다.
/// 토스트처럼 따로 뜨는 창에도 붙는다.
@MainActor
enum TouchIndicator {
    private static var observer: NSObjectProtocol?

    static func install() {
        observer = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeVisibleNotification,
            object: nil,
            queue: .main,
        ) { note in
            let window = note.object as? UIWindow
            MainActor.assumeIsolated {
                guard let window,
                      !(window.gestureRecognizers ?? []).contains(where: { $0 is TouchTracker })
                else { return }
                window.addGestureRecognizer(TouchTracker())
            }
        }
    }
}

/// 아무것도 알아보지 않고 터치만 지켜본다. 다른 제스처와 터치 전달을 막지 않는다.
private final class TouchTracker: UIGestureRecognizer {
    private var dots: [ObjectIdentifier: UIView] = [:]
    private let size: CGFloat = 40

    init() {
        super.init(target: nil, action: nil)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    override func canPrevent(_: UIGestureRecognizer) -> Bool {
        false
    }

    /// 다른 제스처(드래그 등)가 알아봐도 실패하지 않고 손가락을 끝까지 따라간다.
    override func canBePrevented(by _: UIGestureRecognizer) -> Bool {
        false
    }

    override func reset() {
        super.reset()
        lift(Set(), all: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent) {
        guard let window = view as? UIWindow else { return }
        for touch in touches {
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            dot.isUserInteractionEnabled = false
            dot.layer.cornerRadius = size / 2
            dot.backgroundColor = UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.32) : UIColor(white: 0.2, alpha: 0.18)
            }
            dot.layer.borderWidth = 1.5
            dot.layer.borderColor = UIColor(white: 1, alpha: 0.6)
                .resolvedColor(with: window.traitCollection).cgColor
            dot.center = touch.location(in: window)
            dot.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            dot.alpha = 0
            window.addSubview(dot)
            dots[ObjectIdentifier(touch)] = dot
            UIView.animate(withDuration: 0.12) {
                dot.transform = .identity
                dot.alpha = 1
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent) {
        guard let window = view as? UIWindow else { return }
        for touch in touches {
            dots[ObjectIdentifier(touch)]?.center = touch.location(in: window)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent) {
        lift(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent) {
        lift(touches)
    }

    private func lift(_ touches: Set<UITouch>, all: Bool = false) {
        let keys = all ? Array(dots.keys) : touches.map(ObjectIdentifier.init)
        for key in keys {
            guard let dot = dots.removeValue(forKey: key) else { continue }
            UIView.animate(withDuration: 0.25) {
                dot.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                dot.alpha = 0
            } completion: { _ in
                dot.removeFromSuperview()
            }
        }
        if dots.isEmpty, !all {
            state = .failed
        }
    }
}
