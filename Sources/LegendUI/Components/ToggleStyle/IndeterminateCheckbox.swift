import SwiftUI

// MARK: - CheckboxState

/// 체크박스의 3가지 상태를 나타내는 열거형
public enum CheckboxState: Sendable, Equatable {
    case unchecked
    case checked
    case indeterminate
}

// MARK: - IndeterminateCheckbox

/// 3상태(unchecked, checked, indeterminate)를 지원하는 체크박스 컴포넌트
///
/// 일반적인 Toggle의 ToggleStyle로는 3상태를 지원할 수 없어 별도의 View 컴포넌트로 구현됨.
/// 부모-자식 체크박스 패턴에서 "일부 선택됨" 상태를 표현할 때 사용.
///
/// 탭 동작:
/// - indeterminate → unchecked
/// - unchecked → checked
/// - checked → unchecked
///
/// ```swift
/// @State private var state: CheckboxState = .indeterminate
///
/// IndeterminateCheckbox("전체 선택", state: $state)
/// ```
public struct IndeterminateCheckbox<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.legendTheme) private var theme

    @Binding private var state: CheckboxState
    private let sizeType: CheckboxSizeType
    private let isInvalid: Bool
    private let label: Label

    @State private var isHovered = false
    @State private var isPressed = false

    private var size: CheckboxSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    /// Creates a new indeterminate checkbox with a custom label.
    ///
    /// - Parameters:
    ///   - state: A binding to the checkbox state.
    ///   - size: The size preset for the checkbox. Defaults to `.md`.
    ///   - isInvalid: When true, displays the checkbox in an error state with danger colors.
    ///   - label: A view builder that creates the label view.
    public init(
        state: Binding<CheckboxState>,
        size: CheckboxSizeType = .md,
        isInvalid: Bool = false,
        @ViewBuilder label: () -> Label,
    ) {
        self._state = state
        self.sizeType = size
        self.isInvalid = isInvalid
        self.label = label()
    }

    public var body: some View {
        HStack(spacing: size.spacing) {
            checkboxBox()
            label
                .fontStyle(size.fontStyle)
                .foregroundStyle(labelColor)
        }
        .onTapGesture {
            handleTap()
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false },
        )
        .opacity(isEnabled ? 1 : theme.layout.opacity.disabled)
    }

    // MARK: - Tap Handler

    private func handleTap() {
        guard isEnabled else { return }

        switch state {
        case .indeterminate:
            state = .unchecked
        case .unchecked:
            state = .checked
        case .checked:
            state = .unchecked
        }
    }

    // MARK: - Checkbox Box

    @ViewBuilder
    private func checkboxBox() -> some View {
        let isActive = state != .unchecked

        ZStack {
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .fill(boxBackgroundColor)

            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .stroke(boxBorderColor, lineWidth: isActive ? 0 : 1.5)

            // Checkmark (checked 상태)
            CheckmarkShape()
                .trim(from: 0, to: state == .checked ? 1 : 0)
                .stroke(
                    iconColor,
                    style: StrokeStyle(
                        lineWidth: size.iconStrokeWidth,
                        lineCap: .round,
                        lineJoin: .round,
                    ),
                )
                .frame(width: size.iconSize, height: size.iconSize)
                .opacity(state == .checked ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: state)

            // Minus (indeterminate 상태)
            MinusShape()
                .trim(from: 0, to: state == .indeterminate ? 1 : 0)
                .stroke(
                    iconColor,
                    style: StrokeStyle(
                        lineWidth: size.iconStrokeWidth,
                        lineCap: .round,
                    ),
                )
                .frame(width: size.iconSize, height: size.iconSize)
                .opacity(state == .indeterminate ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: state)
        }
        .frame(width: size.boxSize, height: size.boxSize)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: state)
    }

    // MARK: - Colors

    private var boxBackgroundColor: Color {
        let isActive = state != .unchecked

        if isActive {
            if isInvalid {
                return theme.colors.danger.default
            }
            if isHovered {
                return theme.colors.accent.default.opacity(0.9)
            }
            return theme.colors.accent.default
        } else {
            if isHovered {
                return theme.colors.surface.secondary
            }
            return theme.colors.surface.primary
        }
    }

    private var boxBorderColor: Color {
        if isInvalid {
            return theme.colors.danger.default
        }
        if state != .unchecked {
            return .clear
        }
        if isHovered {
            return theme.colors.foreground.muted
        }
        return theme.colors.border
    }

    private var iconColor: Color {
        if isInvalid {
            return theme.colors.danger.foreground
        }
        return theme.colors.accent.foreground
    }

    private var labelColor: Color {
        if !isEnabled {
            return theme.colors.disabled.foreground
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - Minus Shape

/// 가로선(-) 경로를 그리는 Shape (trim 애니메이션 지원)
struct MinusShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))

        return path
    }
}

// MARK: - Convenience Initializers

extension IndeterminateCheckbox where Label == Text {
    /// Creates a new indeterminate checkbox with a text label.
    ///
    /// - Parameters:
    ///   - title: The text to display as the label.
    ///   - state: A binding to the checkbox state.
    ///   - size: The size preset for the checkbox. Defaults to `.md`.
    ///   - isInvalid: When true, displays the checkbox in an error state.
    public init(
        _ title: String,
        state: Binding<CheckboxState>,
        size: CheckboxSizeType = .md,
        isInvalid: Bool = false,
    ) {
        self._state = state
        self.sizeType = size
        self.isInvalid = isInvalid
        self.label = Text(title)
    }
}

extension IndeterminateCheckbox where Label == EmptyView {
    /// Creates a new indeterminate checkbox without a label.
    ///
    /// - Parameters:
    ///   - state: A binding to the checkbox state.
    ///   - size: The size preset for the checkbox. Defaults to `.md`.
    ///   - isInvalid: When true, displays the checkbox in an error state.
    public init(
        state: Binding<CheckboxState>,
        size: CheckboxSizeType = .md,
        isInvalid: Bool = false,
    ) {
        self._state = state
        self.sizeType = size
        self.isInvalid = isInvalid
        self.label = EmptyView()
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Indeterminate Checkbox States") {
        struct PreviewContainer: View {
            @State private var state1: CheckboxState = .unchecked
            @State private var state2: CheckboxState = .checked
            @State private var state3: CheckboxState = .indeterminate

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Interactive").font(.headline)

                    IndeterminateCheckbox("Unchecked", state: $state1)
                    IndeterminateCheckbox("Checked", state: $state2)
                    IndeterminateCheckbox("Indeterminate", state: $state3)

                    Divider()

                    Text("Invalid States").font(.headline)

                    IndeterminateCheckbox(
                        "Invalid Unchecked",
                        state: .constant(.unchecked),
                        isInvalid: true,
                    )
                    IndeterminateCheckbox(
                        "Invalid Checked",
                        state: .constant(.checked),
                        isInvalid: true,
                    )
                    IndeterminateCheckbox(
                        "Invalid Indeterminate",
                        state: .constant(.indeterminate),
                        isInvalid: true,
                    )

                    Divider()

                    Text("Disabled States").font(.headline)

                    IndeterminateCheckbox("Disabled Unchecked", state: .constant(.unchecked))
                        .disabled(true)
                    IndeterminateCheckbox("Disabled Checked", state: .constant(.checked))
                        .disabled(true)
                    IndeterminateCheckbox(
                        "Disabled Indeterminate",
                        state: .constant(.indeterminate),
                    )
                    .disabled(true)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Indeterminate Checkbox Sizes") {
        struct PreviewContainer: View {
            @State private var state: CheckboxState = .indeterminate

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    IndeterminateCheckbox("Small", state: $state, size: .sm)
                    IndeterminateCheckbox("Medium", state: $state, size: .md)
                    IndeterminateCheckbox("Large", state: $state, size: .lg)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Checkbox Only (No Label)") {
        struct PreviewContainer: View {
            @State private var state: CheckboxState = .indeterminate

            var body: some View {
                HStack(spacing: 16) {
                    IndeterminateCheckbox(state: $state, size: .sm)
                    IndeterminateCheckbox(state: $state, size: .md)
                    IndeterminateCheckbox(state: $state, size: .lg)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Parent-Child Pattern") {
        struct Item: Identifiable {
            let id = UUID()
            var name: String
            var isSelected: Bool
        }

        struct PreviewContainer: View {
            @State private var items = [
                Item(name: "항목 1", isSelected: true),
                Item(name: "항목 2", isSelected: true),
                Item(name: "항목 3", isSelected: false),
            ]

            private var parentState: CheckboxState {
                let selectedCount = items.filter(\.isSelected).count
                if selectedCount == 0 {
                    return .unchecked
                } else if selectedCount == items.count {
                    return .checked
                } else {
                    return .indeterminate
                }
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    IndeterminateCheckbox(
                        "전체 선택",
                        state: Binding(
                            get: { parentState },
                            set: { newState in
                                let isSelected = newState == .checked
                                for i in items.indices {
                                    items[i].isSelected = isSelected
                                }
                            },
                        ),
                    )

                    ForEach($items) { $item in
                        Toggle(item.name, isOn: $item.isSelected)
                            .toggleStyle(.legendCheckbox)
                            .padding(.leading, 24)
                    }
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Dark Mode") {
        struct PreviewContainer: View {
            @State private var state1: CheckboxState = .unchecked
            @State private var state2: CheckboxState = .checked
            @State private var state3: CheckboxState = .indeterminate

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    IndeterminateCheckbox("Unchecked", state: $state1)
                    IndeterminateCheckbox("Checked", state: $state2)
                    IndeterminateCheckbox("Indeterminate", state: $state3)

                    IndeterminateCheckbox(
                        "Invalid",
                        state: .constant(.indeterminate),
                        isInvalid: true,
                    )
                }
                .padding()
                .background(Color("background", bundle: .module))
            }
        }

        return PreviewContainer()
            .preferredColorScheme(.dark)
    }
#endif
