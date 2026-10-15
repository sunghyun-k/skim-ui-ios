# AGENTS.md

이 저장소에서 작업하는 에이전트를 위한 안내.

## 프로젝트 개요

iOS 18+ SwiftUI 디자인 시스템 (토큰 + 컴포넌트). 원칙·토큰·컴포넌트 목록은 README.
여러 앱이 같이 쓴다 — 앱 고유 색·아이콘·도메인 컴포넌트는 각 앱에 둔다.

## 빌드

iOS 전용이라 `swift build`(macOS)는 안 된다. 고친 파일은 `swiftformat`으로 정리한다.

```bash
xcodebuild build -scheme skim-ui-ios -destination 'generic/platform=iOS Simulator' -quiet 2>&1 | grep -E "error:|warning:"
```

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
- README 헤더 이미지는 `Tools/HeaderMaker.swiftpm`이 원본. 고친 뒤 `Tools/make-header.sh` → `docs/`.
