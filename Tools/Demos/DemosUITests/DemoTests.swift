import XCTest

/// 데모 화면을 손가락으로 만진다. 화면마다 시작·끝에 표시를 찍고, `Tools/make-demos.sh`가 그 구간을 잘라 낸다.
///
///     DEMO <이름> sync <시각>        ← 왼쪽 위 `SyncMark`를 누르고 난 시각 (영상에서 번쩍이는 프레임과 맞춘다)
///     DEMO <이름> begin <시각> <무대 x y 너비 높이 (pt)> <화면 너비 (pt)>
///     DEMO <이름> end <시각>
@MainActor
final class DemoTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
    }

    func testToast() {
        record("toast", targets: ["Copy", "Sync", "Go offline"]) { at in
            tap(at("Copy"))
            wait(2.2)
            tap(at("Sync"))
            wait(0.9)
            tap(at("Go offline"))
            wait(1.4)
            press(element("Close"), hold: 0.25)
            wait(2.6) // 앞으로 나온 경고 토스트가 저절로 닫힐 때까지
        }
    }

    func testSlider() {
        record("slider") { _ in
            let slider = app.descendants(matching: .any)["slider"]
            let frame = slider.frame
            // 양옆 −/+ 버튼(32pt) + 간격 8pt. 손잡이는 트랙 왼쪽 반원 뒤 ~ 오른쪽 반원 가운데.
            let track = (x: frame.minX + 40, width: frame.width - 80, y: frame.minY + 16)
            @MainActor func knob(_ value: Int) -> XCUICoordinate {
                let leading = 16 + 4.5
                let x = track.x + leading + (track.width - 16 - leading) * CGFloat(value - 1) / 6
                return point(x, track.y)
            }
            let minus = point(frame.minX + 16, track.y)

            drag(from: knob(3), to: knob(7))
            wait(0.5)
            minus.press(forDuration: 0.12)
            wait(0.4)
            minus.press(forDuration: 0.12)
            wait(0.5)
            drag(from: knob(5), to: knob(3))
            wait(0.6)
        }
    }

    func testSegmented() {
        record("segmented", targets: ["Day", "Week", "Month"]) { at in
            tap(at("Week"))
            wait(0.8)
            tap(at("Month"))
            wait(0.8)
            drag(from: at("Month"), to: at("Day"))
            wait(0.8)
        }
    }

    func testExpandable() {
        let questions = [
            "Why did the total change?",
            "Can I change the reset day?",
            "Is my data shared?",
        ]
        record("expandable", targets: [questions[0]]) { at in
            // 하나를 펼치면 다른 것은 접힌다. 첫 행 말고는 밀려나므로 그때그때 찾는다.
            tap(at(questions[0]))
            wait(1.0)
            for question in questions.dropFirst() + [questions[2]] {
                press(element(question))
                wait(1.0)
            }
        }
    }

    func testSkeleton() {
        record("skeleton", targets: ["Refresh"]) { at in
            tap(at("Refresh"))
            wait(2.6)
        }
    }

    func testSelection() {
        let labels = [
            "Plus",
            "Pro",
            "No discount",
            "Shortcuts",
            "Widgets",
            "Basic",
            "Limited time",
            "Widgets",
            "Shortcuts",
        ]
        record("selection", targets: labels) { at in
            for label in labels {
                tap(at(label))
                wait(0.55)
            }
            wait(0.3)
        }
    }

    func testTiles() {
        let labels = ["Dark", "Auto", "Light", "Sunset", "Mono", "Ocean"]
        record("tiles", targets: labels) { at in
            for label in labels {
                tap(at(label))
                wait(0.7)
            }
        }
    }

    // MARK: - 도구

    /// `targets`는 표시를 찍기 전에 미리 자리를 재 둔다 (누를 때마다 찾으면 느려서 영상이 늘어진다).
    private func record(
        _ name: String,
        targets: [String] = [],
        _ body: (_ at: (String) -> XCUICoordinate) -> Void,
    ) {
        app = XCUIApplication()
        app.launchArguments = ["--demo", name]
        app.launch()
        let stage = app.descendants(matching: .any)["stage"]
        XCTAssertTrue(stage.waitForExistence(timeout: 10))
        wait(0.8) // 실행 애니메이션이 끝나게
        var points: [String: XCUICoordinate] = [:]
        for label in targets {
            let target = element(label)
            XCTAssertTrue(target.waitForExistence(timeout: 5), label)
            points[label] = point(target.frame.midX, target.frame.midY)
        }
        // 누르는 동작이 끝난 뒤에 시각을 찍는다. 다른 탭도 부른 뒤 같은 만큼 늦게 닿으므로 그만큼 앞당겨 자르게 된다.
        point(28, 82).press(forDuration: 0.05) // SyncMark 가운데
        print("DEMO \(name) sync \(Date().timeIntervalSince1970)")
        wait(0.5)
        let f = stage.frame
        let width = app.windows.firstMatch.frame.width
        print(
            "DEMO \(name) begin \(Date().timeIntervalSince1970) \(f.minX) \(f.minY) \(f.width) \(f.height) \(width)",
        )
        wait(0.4)
        body { points[$0]! }
        print("DEMO \(name) end \(Date().timeIntervalSince1970)")
        wait(1.0) // 녹화 시각이 조금 밀려도 끝에 홈 화면이 담기지 않게
        app.terminate()
    }

    /// 글자·버튼·셀 무엇이든 이름이나 글자로 찾는다.
    private func element(_ label: String) -> XCUIElement {
        app.descendants(matching: .any)[label].firstMatch
    }

    private func point(_ x: CGFloat, _ y: CGFloat) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y))
    }

    /// 손가락이 보이게 잠깐 눌렀다 뗀다.
    private func tap(_ point: XCUICoordinate) {
        point.press(forDuration: 0.12)
    }

    private func press(_ element: XCUIElement, hold: TimeInterval = 0.12) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "\(element)")
        element.press(forDuration: hold)
    }

    /// 잡고 → 천천히 끌고 → 잠깐 버티다 놓는다.
    private func drag(from start: XCUICoordinate, to end: XCUICoordinate) {
        start.press(forDuration: 0.3, thenDragTo: end, withVelocity: 260, thenHoldForDuration: 0.35)
    }

    /// 앱이 한가해지길 기다리지 않고 그냥 흘려보낸다 (스피너·shimmer 동안에도).
    private func wait(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
}
