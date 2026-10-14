import SwiftUI

/// 입력 항목 머리: "별칭 (선택)" ……… [오른쪽 값·버튼].
public struct FieldHeader<Trailing: View>: View {
    let title: String
    let isOptional: Bool
    let trailing: Trailing

    public init(
        _ title: String,
        isOptional: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.title = title
        self.isOptional = isOptional
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.s) {
            Text(
                "\(Text(title).foregroundStyle(Palette.ink2))\(Text(isOptional ? String(localized: " (Optional)", bundle: .module) : "").foregroundStyle(Palette.ink4))",
            )
            .textRole(.footnote)
            Spacer(minLength: Space.s)
            trailing
        }
    }
}

/// 입력 항목 하나: 머리 + 내용 + (선택) 도움말.
public struct Field<Content: View>: View {
    let title: String
    let isOptional: Bool
    let help: String?
    let content: Content

    public init(
        _ title: String,
        isOptional: Bool = false,
        help: String? = nil,
        @ViewBuilder content: () -> Content,
    ) {
        self.title = title
        self.isOptional = isOptional
        self.help = help
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            FieldHeader(title, isOptional: isOptional)
            content
            if let help {
                Text(help)
                    .textRole(.footnote)
                    .foregroundStyle(Palette.ink4)
            }
        }
    }
}

/// 입력칸 모양 (`TextField(...).textFieldStyle(.field(unit: "원"))`).
/// 옅은 판 + 1pt 테두리, 입력 중이면 테두리가 글자색. 앞에 아이콘(검색), 뒤에 단위.
/// `large`: 금액처럼 숫자가 주인공인 칸 (20pt).
@MainActor
public struct FieldTextFieldStyle: TextFieldStyle {
    let icon: Icon?
    let unit: String?
    let large: Bool

    public nonisolated init(icon: Icon? = nil, unit: String? = nil, large: Bool = false) {
        self.icon = icon
        self.unit = unit
        self.large = large
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        FieldBox(icon: icon, unit: unit, large: large) { configuration }
    }
}

extension TextFieldStyle where Self == FieldTextFieldStyle {
    public static var field: FieldTextFieldStyle {
        FieldTextFieldStyle()
    }

    public static func field(
        icon: Icon? = nil,
        unit: String? = nil,
        large: Bool = false,
    ) -> FieldTextFieldStyle {
        FieldTextFieldStyle(icon: icon, unit: unit, large: large)
    }
}

/// 입력칸 틀. `TextField` 말고 날짜·메뉴 값처럼 칸 모양만 필요한 곳도 쓴다.
public struct FieldBox<Content: View>: View {
    let icon: Icon?
    let unit: String?
    let large: Bool
    let content: Content

    @FocusState private var isFocused: Bool

    public init(
        icon: Icon? = nil,
        unit: String? = nil,
        large: Bool = false,
        @ViewBuilder content: () -> Content,
    ) {
        self.icon = icon
        self.unit = unit
        self.large = large
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.control + 2, style: .continuous)
        HStack(spacing: Space.s) {
            if let icon {
                IconView(icon, size: 16)
                    .foregroundStyle(Palette.ink4)
            }
            content
                .focused($isFocused)
                .textRole(large ? .title : .body)
                .foregroundStyle(Palette.ink1)
                .tint(Palette.ink1)
            if let unit {
                Text(unit)
                    .textRole(large ? .callout : .footnote)
                    .foregroundStyle(Palette.ink4)
            }
        }
        .padding(.horizontal, large ? 14 : 12)
        .frame(minHeight: large ? 50 : 44)
        .background {
            shape.fill(Palette.fill3)
                .insetRing(shape, isFocused ? 0.5 : 0, width: 1)
        }
        .contentShape(shape)
        .onTapGesture { isFocused = true }
        .animation(.soft, value: isFocused)
    }
}

/// 값을 비워 둘 수 있는 단계 슬라이더 (다 쓴 뒤 속도·통화·문자).
/// 머리: 이름 ……… 값 [지우기]. 비어 있으면 슬라이더가 45%로 흐리고 값 자리에 `placeholder`.
/// 비어 있을 때 슬라이더를 만지면 `initial`에서 시작한다.
/// `isOptional`이 false면 지우기가 없다 (월 제공량). `showsOptionalMark`: 이름 옆 "(선택)" — 등록 단계는 화면 전체가 선택 정보라
/// 뺀다.
/// `accessory`: 값 옆 글자 버튼 ("직접 입력") — 단계에 없는 값을 받는 칸을 연다.
public struct FieldSlider<Value: Hashable>: View {
    let title: String
    let isOptional: Bool
    let showsOptionalMark: Bool
    @Binding var selection: Value?
    let steps: [Value]
    let initial: Value
    let placeholder: String?
    let label: (Value) -> String
    let accessory: (title: String, action: () -> Void)?

    public init(
        _ title: String,
        isOptional: Bool = true,
        selection: Binding<Value?>,
        steps: [Value],
        showsOptionalMark: Bool = true,
        initial: Value? = nil,
        placeholder: String? = nil,
        accessory: (title: String, action: () -> Void)? = nil,
        label: @escaping (Value) -> String,
    ) {
        self.title = title
        self.isOptional = isOptional
        self.showsOptionalMark = showsOptionalMark
        _selection = selection
        self.steps = steps
        self.initial = initial ?? steps[0]
        self.placeholder = placeholder
        self.label = label
        self.accessory = accessory
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            FieldHeader(title, isOptional: isOptional && showsOptionalMark) {
                HStack(alignment: .firstTextBaseline, spacing: Space.s) {
                    Text(selection.map(label) ?? placeholder ?? String(
                        localized: "Not set",
                        bundle: .module,
                    ))
                    .textRole(.headline)
                    .foregroundStyle(selection == nil ? Palette.ink4 : Palette.ink1)
                    .contentTransition(.numericText())
                    .animation(.roll, value: selection)
                    if isOptional, selection != nil {
                        Button(String(localized: "Clear", bundle: .module)) { selection = nil }
                            .buttonStyle(.quiet)
                            .transition(.opacity)
                    }
                    if let accessory {
                        Button(accessory.title, action: accessory.action)
                            .buttonStyle(.quiet)
                    }
                }
            }
            SteppedSlider(
                selection: Binding(get: { selection ?? initial }, set: { selection = $0 }),
                steps: steps,
                label: label,
            )
            .opacity(selection == nil ? 0.45 : 1)
        }
        .animation(.soft, value: selection == nil)
    }
}

/// 숨겨 둔 항목을 여는 글자 버튼 ("+ 일 제공량이 있는 요금제인가요?", "+ 사용량 초기화 날짜 바꾸기").
/// 열린 뒤에는 `+` 없이 닫는 문구를 쓴다 ("일 제공량 없음").
public struct RevealButton: View {
    let title: String
    let isExpanded: Bool
    let action: () -> Void

    public init(_ title: String, isExpanded: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isExpanded = isExpanded
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if !isExpanded {
                    IconView(.plus, size: 12)
                }
                Text(title)
            }
            .frame(minHeight: 44)
        }
        .buttonStyle(QuietButtonStyle(color: Palette.ink2))
    }
}

/// 등록 단계 진행 표시: 짧은 캡슐들, 지금 단계만 길고 테마색, 나머지는 옅게.
/// `onSelect`가 있으면 지나온 단계를 눌러 돌아갈 수 있다.
public struct StepProgress: View {
    let count: Int
    let current: Int
    let onSelect: ((Int) -> Void)?

    public init(count: Int, current: Int, onSelect: ((Int) -> Void)? = nil) {
        self.count = count
        self.current = current
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< count, id: \.self) { step in
                Capsule()
                    .fill(step == current ? Palette.theme : Palette.fill1)
                    .frame(width: step == current ? 24 : 12, height: 3)
                    // 눌리는 자리는 막대보다 넉넉하게.
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                    .contentShape(.rect)
                    .padding(.horizontal, -2)
                    .onTapGesture {
                        if step < current {
                            onSelect?(step)
                        }
                    }
            }
        }
        .animation(.strongOut, value: current)
        .accessibilityElement()
        .accessibilityLabel(Text(String(
            localized: "Step \(current + 1) of \(count)",
            bundle: .module,
        )))
    }
}

/// 질문 머리 (등록 단계마다): 큰 질문 + 왜 묻는지 한 줄.
public struct QuestionHeader: View {
    let title: String
    let message: String?

    public init(_ title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .textRole(.pageTitle)
                .foregroundStyle(Palette.ink1)
            if let message {
                Text(message)
                    .textRole(.callout)
                    .foregroundStyle(Palette.ink3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
    }
}
