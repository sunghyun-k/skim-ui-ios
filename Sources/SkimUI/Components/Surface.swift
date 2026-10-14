import SwiftUI

/// 화면 바탕: void 색 (`systemGroupedBackground`).
public struct ScreenBackground: View {
    public init() {}

    public var body: some View {
        Palette.void
            .ignoresSafeArea()
    }
}

/// 카드 면: iOS 그룹 카드처럼 평평한 면 하나. 테두리·그림자·번짐 없이 바탕과의 명도 차로만 나뉜다.
/// 상태와 관계없이 늘 같다 — 상태 색은 게이지·막대·D-day 글자에만 (위젯과 같은 원칙).
public struct CardBackground: View {
    var fill: Color

    public init(fill: Color = Palette.surface) {
        self.fill = fill
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            .fill(fill)
    }
}

extension View {
    /// 카드 하나: 안쪽 여백 + 카드 면.
    public func card(padding: CGFloat = Space.xl) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CardBackground())
            .contentShape(.rect(cornerRadius: Radius.card, style: .continuous))
    }

    /// 화면 아래 고정 막대 (등록 단계 "다음"). iOS 26은 `safeAreaBar` — 스크롤 가장자리 효과가 붙어 `.floating` 버튼 밑으로 내용이
    /// 비친다.
    /// 그 전은 `safeAreaInset`.
    @ViewBuilder
    public func bottomBar(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 26, *) {
            safeAreaBar(edge: .bottom, content: content)
        } else {
            safeAreaInset(edge: .bottom, content: content)
        }
    }

    /// 화면 바탕을 깐다. List·Form은 시스템 배경을 숨기고 이걸 쓴다.
    public func screenBackground() -> some View {
        scrollContentBackground(.hidden)
            .background { ScreenBackground() }
    }
}

/// 카드 안을 나누는 1pt 선.
public struct Hairline: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Palette.hair)
            .frame(height: 1)
    }
}

extension View {
    /// 시스템 Form·List의 섹션을 카드 면으로 (입력 화면은 시스템 컨트롤을 그대로 쓰고 면만 맞춘다).
    public func formSection() -> some View {
        listRowBackground(Palette.surface)
            .listRowSeparatorTint(Palette.hair)
    }
}
