# AGENTS.md

이 저장소에서 작업하는 에이전트를 위한 안내.

## 프로젝트 개요

iOS 18+ · macOS 26+ SwiftUI 디자인 시스템 (토큰 + 컴포넌트). 원칙·토큰·컴포넌트 목록은 README.
여러 앱이 같이 쓴다 — 앱 고유 색·아이콘·도메인 컴포넌트는 각 앱에 둔다.

## 빌드

iOS·macOS 둘 다 빌드한다. 고친 파일은 `swiftformat`으로 정리한다.

```bash
xcodebuild build -scheme skim-ui-ios -destination 'generic/platform=iOS Simulator' -quiet 2>&1 | grep -E "error:|warning:"
xcodebuild build -scheme skim-ui-ios -destination 'generic/platform=macOS' -quiet 2>&1 | grep -E "error:|warning:"
```

## macOS

- 최소 버전: iOS 는 18 그대로 둔다(다른 앱이 쓴다). macOS 는 26.
- UIKit 에 기대는 곳은 `#if os(iOS)` 로 나누고 macOS 는 SwiftUI·AppKit 으로 대신한다. iOS 동작은 바꾸지 않는다.
  - 색(`Color(light:dark:)`): `NSColor(name:dynamicProvider:)` + `NSAppearance.bestMatch`.
  - `PressableButton`·`ScrubGesture`·`HorizontalDragGesture`: `DragGesture(minimumDistance: 0)`. 마우스 끌기는 스크롤과 겹치지 않아
    길게 누르기·방향 판정·겹친 버튼 고르기가 없다(안쪽 버튼 제스처가 먼저 받는다).
  - 토스트: 떠 있는 통과 창(`PassthroughWindow`) 대신 `installToasts()` 를 건 뷰 위에 겹친다. 시트·다른 창 위로는 뜨지 않는다.
  - `dismissesKeyboardOnTap()`: 아무것도 하지 않는다.
- iOS 전용 수식어(`navigationBarTitleDisplayMode`, `keyboardType`, `fullScreenCover`, `statusBarHidden` 등)는 `#if os(iOS)` 안에 둔다.

## 규칙

- 외부 패키지 의존성을 두지 않는다.
- 화면 코드에서 시스템 색을 직접 쓰지 않는다 → `Palette`, `.textRole(_:)`.
- 아이콘은 `Icon`을 먼저 쓰고, 맞는 모양이 없을 때만 SF Symbols.
- 테마색은 `AccentTheme.current`에서만 나온다. 컴포넌트에 라임 같은 값을 박지 않는다.
- 렌더 스레드에서 불리는 것(동적 색 클로저·`Shape.path`)은 `nonisolated`.
- 버튼 스타일은 `PrimitiveButtonStyle` + `PressableButton` (스크롤 뷰 안에서도 바로 눌림).
- 라이브러리 안의 문구는 `String(localized: "...", bundle: .module)` + `Resources/Localizable.xcstrings` (en 기준, ko 번역).
- 아이콘은 `Tools/icons.py`가 원본. 고친 뒤 `python3 Tools/icons.py`.
- 컴포넌트를 더하면 `Storybook`과 README 표에도 넣는다.
- README 이미지는 저장소에 넣지 않는다 (SwiftPM이 저장소를 통째로 받는다). `Tools/out/`에 만든 뒤 사용자가 GitHub 이슈
  댓글에 올려 생긴 `user-attachments` 주소를 README에 쓴다.
  - 헤더: `Tools/HeaderMaker.swiftpm`이 원본. 고친 뒤 `Tools/make-header.sh`.
  - 데모 애니메이션: `Tools/Demos`(데모 앱 + 손가락을 움직이는 UI 테스트)가 원본. 보이는 동작을 바꾸면
    `Tools/make-demos.sh [데모 이름]`.
