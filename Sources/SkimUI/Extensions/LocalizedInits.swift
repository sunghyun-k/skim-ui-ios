import SwiftUI

// MARK: - LocalizedStringResource 편의 init

// 앱은 xcstrings가 만든 `LocalizedStringResource` 심볼(`.settingsTitle`)로 문구를 넘긴다.
// 컴포넌트는 `String`을 받으므로 여기서 `String(localized:)`로 풀어 기존 init에 넘긴다.
// 모두 `@_disfavoredOverload`라 문자열 리터럴(`RowGroup("설정")`)은 그대로 `String` init으로 간다.
// 숫자·금액처럼 데이터인 값(`value`)은 `String` 그대로 둔다.

extension LocalizedStringResource? {
    fileprivate var string: String? {
        map { String(localized: $0) }
    }
}

// MARK: - Chips

extension ToneChip {
    @_disfavoredOverload
    public init(_ text: LocalizedStringResource, tone: Tone, compact: Bool = false) {
        self.init(String(localized: text), tone: tone, compact: compact)
    }
}

extension ValueText {
    @_disfavoredOverload
    public init(_ value: String, unit: LocalizedStringResource?, role: TextRole = .hero) {
        self.init(value, unit: unit.string, role: role)
    }
}

// MARK: - Controls

extension SegmentedControl {
    @_disfavoredOverload
    public init(
        selection: Binding<Value>,
        options: [(value: Value, label: LocalizedStringResource)],
    ) {
        self.init(
            selection: selection,
            options: options.map { ($0.value, String(localized: $0.label)) },
        )
    }
}

// MARK: - Feedback

extension Banner {
    @_disfavoredOverload
    public init(
        icon: Icon,
        title: LocalizedStringResource? = nil,
        text: LocalizedStringResource,
        tone: Tone = .neutral,
        actionTitle: LocalizedStringResource? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
    ) {
        self.init(
            icon: icon,
            title: title.map { String(localized: $0) },
            text: String(localized: text),
            tone: tone,
            actionTitle: actionTitle.map { String(localized: $0) },
            action: action,
            onDismiss: onDismiss,
        )
    }
}

extension EmptyState {
    @_disfavoredOverload
    public init(
        icon: Icon,
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        @ViewBuilder actions: () -> Actions = { EmptyView() },
    ) {
        self.init(
            icon: icon,
            title: String(localized: title),
            message: message.string,
            actions: actions,
        )
    }
}

// MARK: - Form fields

extension FieldHeader {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        isOptional: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.init(String(localized: title), isOptional: isOptional, trailing: trailing)
    }
}

extension Field {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        isOptional: Bool = false,
        help: LocalizedStringResource? = nil,
        @ViewBuilder content: () -> Content,
    ) {
        self.init(
            String(localized: title),
            isOptional: isOptional,
            help: help.string,
            content: content,
        )
    }
}

extension FieldTextFieldStyle {
    @_disfavoredOverload
    public nonisolated init(
        icon: Icon? = nil,
        unit: LocalizedStringResource?,
        large: Bool = false,
    ) {
        self.init(icon: icon, unit: unit.string, large: large)
    }
}

extension TextFieldStyle where Self == FieldTextFieldStyle {
    @_disfavoredOverload
    public static func field(
        icon: Icon? = nil,
        unit: LocalizedStringResource?,
        large: Bool = false,
    ) -> FieldTextFieldStyle {
        FieldTextFieldStyle(icon: icon, unit: unit.string, large: large)
    }
}

extension FieldBox {
    @_disfavoredOverload
    public init(
        icon: Icon? = nil,
        unit: LocalizedStringResource?,
        large: Bool = false,
        @ViewBuilder content: () -> Content,
    ) {
        self.init(icon: icon, unit: unit.string, large: large, content: content)
    }
}

extension FieldSlider {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        isOptional: Bool = true,
        selection: Binding<Value?>,
        steps: [Value],
        showsOptionalMark: Bool = true,
        initial: Value? = nil,
        placeholder: LocalizedStringResource? = nil,
        accessory: (title: LocalizedStringResource, action: () -> Void)? = nil,
        label: @escaping (Value) -> String,
    ) {
        self.init(
            String(localized: title),
            isOptional: isOptional,
            selection: selection,
            steps: steps,
            showsOptionalMark: showsOptionalMark,
            initial: initial,
            placeholder: placeholder.string,
            accessory: accessory.map { (String(localized: $0.title), $0.action) },
            label: label,
        )
    }
}

extension RevealButton {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        isExpanded: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.init(String(localized: title), isExpanded: isExpanded, action: action)
    }
}

extension QuestionHeader {
    @_disfavoredOverload
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource? = nil) {
        self.init(String(localized: title), message: message.string)
    }
}

// MARK: - Selection

extension SelectChip {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        detail: LocalizedStringResource? = nil,
        isSelected: Bool,
        shape: Shape = .capsule,
        action: @escaping () -> Void,
    ) {
        self.init(
            String(localized: title),
            detail: detail.string,
            isSelected: isSelected,
            shape: shape,
            action: action,
        )
    }
}

extension ChoiceCard {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        isSelected: Bool,
        action: @escaping () -> Void,
    ) {
        self.init(
            String(localized: title),
            message: message.string,
            isSelected: isSelected,
            action: action,
        )
    }
}

extension OptionRow {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        note: LocalizedStringResource? = nil,
        isSelected: Bool,
        isMuted: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.init(
            String(localized: title),
            note: note.string,
            isSelected: isSelected,
            isMuted: isMuted,
            action: action,
        )
    }
}

extension SheetHeader {
    @_disfavoredOverload
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource? = nil) {
        self.init(String(localized: title), message: message.string)
    }
}

// MARK: - Rows

extension RowGroup {
    @_disfavoredOverload
    public init(_ title: LocalizedStringResource?, @ViewBuilder content: () -> Content) {
        self.init(title.string, content: content)
    }
}

extension SectionTitle {
    @_disfavoredOverload
    public init(_ text: LocalizedStringResource, trailing: LocalizedStringResource? = nil) {
        self.init(String(localized: text), trailing: trailing.string)
    }
}

// MARK: - Readouts

extension StatSplit.Item {
    @_disfavoredOverload
    public init(label: LocalizedStringResource, value: String, valueColor: Color = Palette.ink1) {
        self.init(label: String(localized: label), value: value, valueColor: valueColor)
    }
}

extension MeterRow {
    @_disfavoredOverload
    public init(
        value: String,
        caption: LocalizedStringResource,
        progress: Double? = nil,
        color: Color = Palette.theme,
        footnote: LocalizedStringResource? = nil,
        valueColor: Color = Palette.ink1,
        valueIcon: Icon? = nil,
    ) {
        self.init(
            value: value,
            caption: String(localized: caption),
            progress: progress,
            color: color,
            footnote: footnote.string,
            valueColor: valueColor,
            valueIcon: valueIcon,
        )
    }
}

extension LabeledRow {
    @_disfavoredOverload
    public init(
        _ label: LocalizedStringResource,
        value: String,
        note: LocalizedStringResource? = nil,
        isMuted: Bool = false,
        actionTitle: LocalizedStringResource? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.init(
            String(localized: label),
            value: value,
            note: note.string,
            isMuted: isMuted,
            actionTitle: actionTitle.string,
            action: action,
        )
    }
}

extension ActionRow {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        isDestructive: Bool = false,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.init(
            String(localized: title),
            subtitle: subtitle.string,
            isDestructive: isDestructive,
            leading: leading,
            trailing: trailing,
        )
    }
}

extension ActionRow where Leading == EmptyView {
    @_disfavoredOverload
    public init(
        _ title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        isDestructive: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    ) {
        self.init(
            String(localized: title),
            subtitle: subtitle.string,
            isDestructive: isDestructive,
            trailing: trailing,
        )
    }
}

extension Notice {
    @_disfavoredOverload
    public init(
        _ text: LocalizedStringResource,
        actionTitle: LocalizedStringResource? = nil,
        action: (() -> Void)? = nil,
    ) {
        self.init(String(localized: text), actionTitle: actionTitle.string, action: action)
    }
}

// MARK: - Toast

extension ToastValue {
    @_disfavoredOverload
    public init(
        id: UUID = UUID(),
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        type: ToastType = .default,
        icon: Icon? = nil,
        systemImage: String? = nil,
        duration: TimeInterval? = 3.0,
        showCloseButton: Bool? = nil,
    ) {
        self.init(
            id: id,
            title: String(localized: title),
            message: message.string,
            type: type,
            icon: icon,
            systemImage: systemImage,
            duration: duration,
            showCloseButton: showCloseButton,
        )
    }
}

#if DEBUG
    /// 컴파일 확인: 리터럴은 String init, 리소스는 이 파일의 init으로 모호함 없이 풀린다.
    @MainActor
    private func localizedInitsCompileCheck() {
        let key = LocalizedStringResource("key")
        let text = "dynamic"
        _ = RowGroup("literal") { EmptyView() }
        _ = RowGroup { EmptyView() }
        _ = RowGroup(key) { EmptyView() }
        _ = SectionTitle("literal", trailing: "more")
        _ = SectionTitle(key, trailing: key)
        _ = ToneChip("literal", tone: .neutral)
        _ = ToneChip(key, tone: .neutral)
        _ = ValueText("1", unit: "GB")
        _ = ValueText(text, unit: key)
        _ = LabeledRow("literal", value: text, note: "note")
        _ = LabeledRow(key, value: text, note: key, actionTitle: key) {}
        _ = ActionRow("literal", subtitle: "sub")
        _ = ActionRow(key, subtitle: key)
        _ = ActionRow(key) { EmptyView() } trailing: { EmptyView() }
        _ = EmptyState(icon: .chevronRight, title: "literal", message: "message")
        _ = EmptyState(icon: .chevronRight, title: key, message: key)
        _ = Field("literal") { EmptyView() }
        _ = Field(key, help: key) { EmptyView() }
        _ = FieldBox(unit: "GB") { EmptyView() }
        _ = FieldBox(unit: key) { EmptyView() }
        _ = FieldTextFieldStyle(unit: "GB")
        _ = FieldTextFieldStyle(unit: key)
        _ = MeterRow(value: text, caption: "caption")
        _ = MeterRow(value: text, caption: key, footnote: key)
        _ = StatSplit.Item(label: "label", value: text)
        _ = StatSplit.Item(label: key, value: text)
        _ = Notice("literal", actionTitle: "go") {}
        _ = Notice(key, actionTitle: key) {}
        _ = SelectChip("literal", isSelected: true) {}
        _ = SelectChip(key, detail: key, isSelected: true) {}
        _ = SegmentedControl(selection: .constant(0), options: [(0, "a"), (1, "b")])
        _ = SegmentedControl(selection: .constant(0), options: [(0, key), (1, key)])
        _ = ToastValue(title: "literal", message: "message")
        _ = ToastValue(title: key, message: key)
        _ = ToastValue(title: text)
    }
#endif
