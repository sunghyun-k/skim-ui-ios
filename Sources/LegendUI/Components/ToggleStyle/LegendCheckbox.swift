import SwiftUI

// MARK: - LegendCheckbox

// MARK: - LegendCheckboxStyle

/// A toggle style that renders a themed checkbox with animated checkmark.
///
/// Use `.legendCheckbox` or `.legendCheckbox(size:isInvalid:)` to apply this style.
public struct LegendCheckboxStyle: ToggleStyle {
    private let sizeType: CheckboxSizeType
    private let isInvalid: Bool

    /// Creates a new checkbox style.
    ///
    /// - Parameters:
    ///   - size: The size preset for the checkbox. Defaults to `.md`.
    ///   - isInvalid: When true, displays the checkbox in an error state with danger colors.
    public init(
        size: CheckboxSizeType = .md,
        isInvalid: Bool = false,
    ) {
        self.sizeType = size
        self.isInvalid = isInvalid
    }

    public func makeBody(configuration: Configuration) -> some View {
        LegendCheckboxStyleView(
            configuration: configuration,
            sizeType: sizeType,
            isInvalid: isInvalid,
        )
    }
}

// MARK: - LegendCheckboxStyleView

private struct LegendCheckboxStyleView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.legendTheme) private var theme

    let configuration: ToggleStyleConfiguration
    let sizeType: CheckboxSizeType
    let isInvalid: Bool

    @State private var isHovered = false
    @State private var isPressed = false

    private var size: CheckboxSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            checkboxBox(isOn: configuration.isOn)
            configuration.label
                .fontStyle(size.fontStyle)
                .foregroundStyle(labelColor)
        }
        .onTapGesture {
            configuration.isOn.toggle()
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

    // MARK: - Checkbox Box

    @ViewBuilder
    private func checkboxBox(isOn: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .fill(boxBackgroundColor(isOn: isOn))

            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .stroke(boxBorderColor(isOn: isOn), lineWidth: isOn ? 0 : 1.5)

            CheckmarkShape()
                .trim(from: 0, to: isOn ? 1 : 0)
                .stroke(
                    checkmarkColor,
                    style: StrokeStyle(
                        lineWidth: size.iconStrokeWidth,
                        lineCap: .round,
                        lineJoin: .round,
                    ),
                )
                .frame(width: size.iconSize, height: size.iconSize)
                .animation(.easeOut(duration: 0.2), value: isOn)
        }
        .frame(width: size.boxSize, height: size.boxSize)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOn)
    }

    // MARK: - Colors

    private func boxBackgroundColor(isOn: Bool) -> Color {
        if isOn {
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

    private func boxBorderColor(isOn: Bool) -> Color {
        if isInvalid {
            return theme.colors.danger.default
        }
        if isOn {
            return .clear
        }
        if isHovered {
            return theme.colors.foreground.muted
        }
        return theme.colors.border
    }

    private var checkmarkColor: Color {
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

// MARK: - Checkmark Shape

/// A shape that draws an animated checkmark path.
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.15, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.25))

        return path
    }
}

// MARK: - ToggleStyle Extension

extension ToggleStyle where Self == LegendCheckboxStyle {
    /// A checkbox toggle style with default size.
    public static var legendCheckbox: LegendCheckboxStyle {
        LegendCheckboxStyle()
    }

    /// A checkbox toggle style with customizable size and validation state.
    ///
    /// - Parameters:
    ///   - size: The size preset for the checkbox. Defaults to `.md`.
    ///   - isInvalid: When true, displays the checkbox in an error state.
    public static func legendCheckbox(
        size: CheckboxSizeType = .md,
        isInvalid: Bool = false,
    ) -> LegendCheckboxStyle {
        LegendCheckboxStyle(size: size, isInvalid: isInvalid)
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Checkbox States") {
        struct PreviewContainer: View {
            @State private var checked1 = false
            @State private var checked2 = true
            @State private var checked3 = false
            @State private var checked4 = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Unchecked", isOn: $checked1)
                        .toggleStyle(.legendCheckbox)

                    Toggle("Checked", isOn: $checked2)
                        .toggleStyle(.legendCheckbox)

                    Toggle("Invalid", isOn: $checked3)
                        .toggleStyle(.legendCheckbox(isInvalid: true))

                    Toggle("Invalid Checked", isOn: $checked4)
                        .toggleStyle(.legendCheckbox(isInvalid: true))

                    Toggle("Disabled", isOn: .constant(false))
                        .toggleStyle(.legendCheckbox)
                        .disabled(true)

                    Toggle("Disabled Checked", isOn: .constant(true))
                        .toggleStyle(.legendCheckbox)
                        .disabled(true)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Checkbox Sizes") {
        struct PreviewContainer: View {
            @State private var sm = true
            @State private var md = true
            @State private var lg = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Small checkbox", isOn: $sm)
                        .toggleStyle(.legendCheckbox(size: .sm))

                    Toggle("Medium checkbox", isOn: $md)
                        .toggleStyle(.legendCheckbox(size: .md))

                    Toggle("Large checkbox", isOn: $lg)
                        .toggleStyle(.legendCheckbox(size: .lg))
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Checkbox Only (No Label)") {
        struct PreviewContainer: View {
            @State private var checked = false

            var body: some View {
                HStack(spacing: 16) {
                    Toggle(isOn: $checked) { EmptyView() }
                        .toggleStyle(.legendCheckbox(size: .sm))

                    Toggle(isOn: $checked) { EmptyView() }
                        .toggleStyle(.legendCheckbox(size: .md))

                    Toggle(isOn: $checked) { EmptyView() }
                        .toggleStyle(.legendCheckbox(size: .lg))
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Dark Mode") {
        struct PreviewContainer: View {
            @State private var checked1 = false
            @State private var checked2 = true
            @State private var checked3 = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Unchecked", isOn: $checked1)
                        .toggleStyle(.legendCheckbox)

                    Toggle("Checked", isOn: $checked2)
                        .toggleStyle(.legendCheckbox)

                    Toggle("Invalid", isOn: $checked3)
                        .toggleStyle(.legendCheckbox(isInvalid: true))
                }
                .padding()
                .background(Color("background", bundle: .module))
            }
        }

        return PreviewContainer()
            .preferredColorScheme(.dark)
    }
#endif
