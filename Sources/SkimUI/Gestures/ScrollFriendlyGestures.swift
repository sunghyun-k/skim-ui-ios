import SwiftUI
#if os(iOS)
    import UIKit
    import UIKit.UIGestureRecognizerSubclass
#endif

#if os(iOS)
    /// 길게 눌러 시작해 누른 채 끄는 동안 위치를 알려 주는 제스처 (막대 훑기).
    /// SwiftUI의 `LongPressGesture` + `DragGesture`는 스크롤 뷰 안에서 손가락을 먼저 잡아 위아래 스크롤이 막힌다.
    /// UIKit 길게 누르기 인식기는 누르는 시간 전에 손가락이 움직이면 실패해 스크롤에 넘기고, 시작한 뒤엔 스크롤을 막는다.
    public struct ScrubGesture: UIGestureRecognizerRepresentable {
        var minimumDuration: TimeInterval
        let onChanged: (CGPoint) -> Void
        let onEnded: () -> Void

        public init(
            minimumDuration: TimeInterval = 0.25,
            onChanged: @escaping (CGPoint) -> Void,
            onEnded: @escaping () -> Void,
        ) {
            self.minimumDuration = minimumDuration
            self.onChanged = onChanged
            self.onEnded = onEnded
        }

        public func makeUIGestureRecognizer(context _: Context) -> UILongPressGestureRecognizer {
            let recognizer = UILongPressGestureRecognizer()
            recognizer.minimumPressDuration = minimumDuration
            return recognizer
        }

        public func handleUIGestureRecognizerAction(
            _ recognizer: UILongPressGestureRecognizer,
            context: Context,
        ) {
            switch recognizer.state {
            case .began, .changed:
                onChanged(context.converter.localLocation)
            case .ended, .cancelled, .failed:
                onEnded()
            default:
                break
            }
        }
    }

    /// 누르거나 가로로 끌어 고르는 제스처 (세그먼트 탭).
    /// 손가락이 세로로 먼저 움직이면 실패해 스크롤에 넘기고, 가로로 먼저 움직이면 끄는 동안 위치를 알려 준다.
    /// 움직이지 않고 떼면 누른 것 (`onEnded`만 불린다).
    public struct HorizontalDragGesture: UIGestureRecognizerRepresentable {
        let onChanged: (CGPoint) -> Void
        let onEnded: (CGPoint) -> Void
        var onCancelled: () -> Void

        public init(
            onChanged: @escaping (CGPoint) -> Void,
            onEnded: @escaping (CGPoint) -> Void,
            onCancelled: @escaping () -> Void = {},
        ) {
            self.onChanged = onChanged
            self.onEnded = onEnded
            self.onCancelled = onCancelled
        }

        public func makeUIGestureRecognizer(context _: Context) -> HorizontalDragRecognizer {
            HorizontalDragRecognizer()
        }

        public func handleUIGestureRecognizerAction(
            _ recognizer: HorizontalDragRecognizer,
            context: Context,
        ) {
            switch recognizer.state {
            case .began, .changed:
                onChanged(context.converter.localLocation)
            case .ended:
                onEnded(context.converter.localLocation)
            case .cancelled, .failed:
                onCancelled()
            default:
                break
            }
        }
    }

    public final class HorizontalDragRecognizer: UIGestureRecognizer {
        /// 방향을 정하는 거리. 스크롤 뷰 팬(약 10pt)보다 먼저 정해야 가로로 끌 때 스크롤에 뺏기지 않는다.
        private let slop: CGFloat = 6
        private var start: CGPoint?

        override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent) {
            guard touches.count == 1, start == nil, let touch = touches.first else {
                state = .failed
                return
            }
            start = touch.location(in: view)
        }

        override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent) {
            guard let start, let touch = touches.first else { return }
            guard state == .possible else {
                state = .changed
                return
            }
            let location = touch.location(in: view)
            let dx = abs(location.x - start.x), dy = abs(location.y - start.y)
            guard max(dx, dy) >= slop else { return }
            state = dx > dy ? .began : .failed
        }

        override public func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
            state = .ended
        }

        override public func touchesCancelled(_: Set<UITouch>, with _: UIEvent) {
            state = .cancelled
        }

        override public func reset() {
            start = nil
        }
    }

#else
    /// macOS: 마우스로 누른 채 끄는 동안 위치를 알려 준다. 스크롤(트랙패드·휠)과 겹치지 않아 길게 누를 필요가 없다.
    public struct ScrubGesture: Gesture {
        public typealias Value = DragGesture.Value

        var minimumDuration: TimeInterval
        let onChanged: (CGPoint) -> Void
        let onEnded: () -> Void

        public init(
            minimumDuration: TimeInterval = 0.25,
            onChanged: @escaping (CGPoint) -> Void,
            onEnded: @escaping () -> Void,
        ) {
            self.minimumDuration = minimumDuration
            self.onChanged = onChanged
            self.onEnded = onEnded
        }

        public var body: some Gesture<Value> {
            DragGesture(minimumDistance: 0)
                .onChanged { onChanged($0.location) }
                .onEnded { _ in onEnded() }
        }
    }

    /// macOS: 누르거나 가로로 끌어 고른다. 가로로 6pt 넘게 끌면 위치를 알려 주고, 움직이지 않고 떼면 `onEnded`만 불린다.
    public struct HorizontalDragGesture: Gesture {
        public typealias Value = DragGesture.Value

        let onChanged: (CGPoint) -> Void
        let onEnded: (CGPoint) -> Void
        var onCancelled: () -> Void

        public init(
            onChanged: @escaping (CGPoint) -> Void,
            onEnded: @escaping (CGPoint) -> Void,
            onCancelled: @escaping () -> Void = {},
        ) {
            self.onChanged = onChanged
            self.onEnded = onEnded
            self.onCancelled = onCancelled
        }

        public var body: some Gesture<Value> {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if abs(value.translation.width) >= 6 {
                        onChanged(value.location)
                    }
                }
                .onEnded { onEnded($0.location) }
        }
    }
#endif

// MARK: - 버튼 누름

/// 디자인 시스템 버튼(`PrimitiveButtonStyle`)의 몸통: 누른 모양을 `content(isPressed)`로 그리고, 떼면 `trigger()`.
/// SwiftUI `ButtonStyle`의 `isPressed`는 스크롤 뷰 안에서 늦게 켜진다 (스크롤 뷰가 터치를 잠깐 붙잡는다).
/// UIKit 인식기는 붙잡히기 전에 터치를 받아 손이 닿자마자 눌린 모양이 되고, 스크롤이 시작되면 취소된다.
public struct PressableButton<Content: View>: View {
    let configuration: PrimitiveButtonStyleConfiguration
    let content: (Bool) -> Content

    @State private var isPressed = false
    @State private var size: CGSize = .zero
    @Environment(\.isEnabled) private var isEnabled

    /// 버튼 밖으로 이만큼까지는 눌린 채로 둔다 (UIKit 버튼처럼).
    private let outset: CGFloat = 30

    public init(
        _ configuration: PrimitiveButtonStyleConfiguration,
        @ViewBuilder content: @escaping (_ isPressed: Bool) -> Content,
    ) {
        self.configuration = configuration
        self.content = content
    }

    public var body: some View {
        content(isPressed)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .gesture(
                PressGesture(
                    area: size.width * size.height,
                    onChanged: { location in
                        let pressed = isEnabled && isInside(location)
                        if pressed != isPressed {
                            isPressed = pressed
                        }
                    },
                    onEnded: { location in
                        isPressed = false
                        if let location, isEnabled, isInside(location) {
                            configuration.trigger()
                        }
                    },
                ),
            )
    }

    private func isInside(_ location: CGPoint) -> Bool {
        CGRect(origin: .zero, size: size).insetBy(dx: -outset, dy: -outset).contains(location)
    }
}

#if os(iOS)
    /// 손이 닿자마자 시작해 손가락 위치를 알려 준다. 떼면 그 위치, 취소되면 nil.
    /// 스크롤 뷰 팬과 같이 인식하고, 스크롤 뷰 안에서 손가락이 움직이면(스크롤) 취소된다.
    struct PressGesture: UIGestureRecognizerRepresentable {
        /// 버튼 면적. 버튼 안에 버튼이 있으면(카드 안 "SIM 연동") 가장 작은 쪽만 눌린다.
        let area: CGFloat
        let onChanged: (CGPoint) -> Void
        let onEnded: (CGPoint?) -> Void

        func makeUIGestureRecognizer(context _: Context) -> PressRecognizer {
            let recognizer = PressRecognizer()
            recognizer.area = area
            return recognizer
        }

        func updateUIGestureRecognizer(_ recognizer: PressRecognizer, context _: Context) {
            recognizer.area = area
        }

        func handleUIGestureRecognizerAction(_ recognizer: PressRecognizer, context: Context) {
            switch recognizer.state {
            case .began, .changed:
                onChanged(context.converter.localLocation)
            case .ended:
                onEnded(context.converter.localLocation)
            case .cancelled, .failed:
                onEnded(nil)
            default:
                break
            }
        }
    }

    final class PressRecognizer: UIGestureRecognizer {
        /// 이만큼 움직이면 스크롤로 보고 취소한다 (스크롤 뷰 팬이 시작하는 거리쯤).
        private let slop: CGFloat = 10
        var area: CGFloat = .infinity
        private var start: CGPoint?
        private var isInScrollView = false
        private var touchKey: ObjectIdentifier?
        /// 터치마다 지금 눌린 인식기.
        private static var pressing: [ObjectIdentifier: Weak] = [:]

        private struct Weak {
            weak var value: PressRecognizer?
            init(_ value: PressRecognizer) {
                self.value = value
            }
        }

        override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent) {
            guard touches.count == 1, start == nil, let touch = touches.first, let view else {
                if state == .possible {
                    state = .failed
                } else {
                    state = .cancelled
                }
                return
            }
            start = touch.location(in: view)
            isInScrollView = Self.hasScrollAncestor(touch.view)
            // 다른 인식기와 서로 막지 않으므로(스크롤 팬 때문) 겹친 버튼끼리는 직접 고른다:
            // 같은 터치를 받은 누름 인식기 중 가장 작은 버튼만 남긴다. 더 작은 게 오면 앞의 것을 취소한다.
            let key = ObjectIdentifier(touch)
            if let current = Self.pressing[key]?.value, current !== self,
               current.state == .began || current.state == .changed
            {
                guard area < current.area else {
                    state = .failed
                    return
                }
                current.state = .cancelled
            }
            Self.pressing[key] = Weak(self)
            touchKey = key
            state = .began
        }

        override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent) {
            guard let start, let touch = touches.first, let view else { return }
            let location = touch.location(in: view)
            if hypot(location.x - start.x, location.y - start.y) > slop, isInScrollView {
                state = .cancelled
                return
            }
            state = .changed
        }

        override func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
            state = .ended
        }

        override func touchesCancelled(_: Set<UITouch>, with _: UIEvent) {
            state = .cancelled
        }

        override func reset() {
            if let touchKey,
               Self.pressing[touchKey].map({ $0.value == nil || $0.value === self }) == true
            {
                Self.pressing[touchKey] = nil
            }
            touchKey = nil
            start = nil
            isInScrollView = false
        }

        /// 스크롤 뷰 팬·다른 제스처를 막지도, 막히지도 않는다.
        override func canPrevent(_: UIGestureRecognizer) -> Bool {
            false
        }

        override func canBePrevented(by _: UIGestureRecognizer) -> Bool {
            false
        }

        /// 스크롤 뷰 안이 아니면 끌어도 취소하지 않는다 (밖으로 나갔다 들어오면 다시 눌림).
        /// 인식기가 붙는 뷰는 스크롤 뷰 바깥(호스팅 뷰)일 수 있어, 손가락이 닿은 뷰에서 올라가며 찾는다.
        private static func hasScrollAncestor(_ view: UIView?) -> Bool {
            var current = view
            while let candidate = current {
                if let scroll = candidate as? UIScrollView, scroll.isScrollEnabled {
                    return true
                }
                current = candidate.superview
            }
            return false
        }
    }

    // MARK: - 키보드 닫기

    extension View {
        /// 입력칸 밖을 누르면 키보드를 닫는다. 터치를 가로채지 않아 버튼·슬라이더·스크롤은 그대로 동작한다.
        public func dismissesKeyboardOnTap() -> some View {
            gesture(KeyboardDismissTap())
        }
    }

    struct KeyboardDismissTap: UIGestureRecognizerRepresentable {
        func makeUIGestureRecognizer(context _: Context) -> KeyboardDismissRecognizer {
            KeyboardDismissRecognizer()
        }

        func handleUIGestureRecognizerAction(
            _ recognizer: KeyboardDismissRecognizer,
            context _: Context,
        ) {
            guard recognizer.state == .ended else { return }
            recognizer.view?.window?.endEditing(true)
        }
    }

    /// 다른 제스처와 서로 막지 않는 탭. 입력칸(과 그 안쪽)을 누른 건 무시한다 — 다른 칸으로 옮겨 갈 때 키보드가 깜빡이지 않게.
    final class KeyboardDismissRecognizer: UITapGestureRecognizer {
        init() {
            super.init(target: nil, action: nil)
            cancelsTouchesInView = false
            delaysTouchesEnded = false
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            let isInTextInput = touches.contains { touch in
                guard let view = touch.view else { return false }
                return sequence(first: view, next: \.superview).contains { $0 is UITextInput }
            }
            if isInTextInput {
                state = .failed
                return
            }
            super.touchesBegan(touches, with: event)
        }

        override func canPrevent(_: UIGestureRecognizer) -> Bool {
            false
        }

        override func canBePrevented(by _: UIGestureRecognizer) -> Bool {
            false
        }
    }
#else
    /// macOS: 누르자마자 시작해 포인터 위치를 알려 준다. 떼면 그 위치.
    /// 안쪽 버튼의 제스처가 바깥 버튼보다 먼저 받으므로 겹친 버튼은 SwiftUI가 고른다.
    struct PressGesture: Gesture {
        typealias Value = DragGesture.Value

        let area: CGFloat
        let onChanged: (CGPoint) -> Void
        let onEnded: (CGPoint?) -> Void

        var body: some Gesture<Value> {
            DragGesture(minimumDistance: 0)
                .onChanged { onChanged($0.location) }
                .onEnded { onEnded($0.location) }
        }
    }

    extension View {
        /// macOS에는 화면 키보드가 없어 아무것도 하지 않는다.
        public func dismissesKeyboardOnTap() -> some View {
            self
        }
    }
#endif
