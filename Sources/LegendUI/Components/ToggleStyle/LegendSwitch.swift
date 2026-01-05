import SwiftUI

// MARK: - LegendSwitch

// MARK: - LegendSwitchStyle

/// A toggle style that renders a themed switch with sliding thumb animation.
///
/// Use `.legendSwitch` or `.legendSwitch(size:isInvalid:)` to apply this style.
public struct LegendSwitchStyle: ToggleStyle {
    private let sizeType: SwitchSizeType
    private let isInvalid: Bool

    /// Creates a new switch style.
    ///
    /// - Parameters:
    ///   - size: The size preset for the switch. Defaults to `.md`.
    ///   - isInvalid: When true, displays the switch in an error state with danger colors.
    public init(
        size: SwitchSizeType = .md,
        isInvalid: Bool = false,
    ) {
        self.sizeType = size
        self.isInvalid = isInvalid
    }

    public func makeBody(configuration: Configuration) -> some View {
        LegendSwitchStyleView(
            configuration: configuration,
            sizeType: sizeType,
            isInvalid: isInvalid,
        )
    }
}

// MARK: - LegendSwitchStyleView

private struct LegendSwitchStyleView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.legendTheme) private var theme

    let configuration: ToggleStyleConfiguration
    let sizeType: SwitchSizeType
    let isInvalid: Bool

    @State private var isHovered = false
    @State private var isPressed = false

    private var size: SwitchSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            switchTrack(isOn: configuration.isOn)
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

    // MARK: - Switch Track

    @ViewBuilder
    private func switchTrack(isOn: Bool) -> some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            // Track background
            Capsule()
                .fill(trackBackgroundColor(isOn: isOn))

            // Track border (only when off)
            if !isOn {
                Capsule()
                    .stroke(trackBorderColor, lineWidth: 1.5)
            }

            // Thumb
            Circle()
                .fill(thumbColor(isOn: isOn))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                .frame(width: size.thumbSize, height: size.thumbSize)
                .padding(size.thumbPadding)
        }
        .frame(width: size.trackWidth, height: size.trackHeight)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOn)
    }

    // MARK: - Colors

    private func trackBackgroundColor(isOn: Bool) -> Color {
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
                return theme.colors.surface.tertiary
            }
            return theme.colors.surface.secondary
        }
    }

    private var trackBorderColor: Color {
        if isInvalid {
            return theme.colors.danger.default
        }
        if isHovered {
            return theme.colors.foreground.muted
        }
        return theme.colors.border
    }

    private func thumbColor(isOn: Bool) -> Color {
        if isInvalid, isOn {
            return theme.colors.danger.foreground
        }
        return .white
    }

    private var labelColor: Color {
        if !isEnabled {
            return theme.colors.disabled.foreground
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - ToggleStyle Extension

extension ToggleStyle where Self == LegendSwitchStyle {
    /// A switch toggle style with default size.
    public static var legendSwitch: LegendSwitchStyle {
        LegendSwitchStyle()
    }

    /// A switch toggle style with customizable size and validation state.
    ///
    /// - Parameters:
    ///   - size: The size preset for the switch. Defaults to `.md`.
    ///   - isInvalid: When true, displays the switch in an error state.
    public static func legendSwitch(
        size: SwitchSizeType = .md,
        isInvalid: Bool = false,
    ) -> LegendSwitchStyle {
        LegendSwitchStyle(size: size, isInvalid: isInvalid)
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Switch States") {
        struct PreviewContainer: View {
            @State private var switch1 = false
            @State private var switch2 = true
            @State private var switch3 = false
            @State private var switch4 = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Off", isOn: $switch1)
                        .toggleStyle(.legendSwitch)

                    Toggle("On", isOn: $switch2)
                        .toggleStyle(.legendSwitch)

                    Toggle("Invalid Off", isOn: $switch3)
                        .toggleStyle(.legendSwitch(isInvalid: true))

                    Toggle("Invalid On", isOn: $switch4)
                        .toggleStyle(.legendSwitch(isInvalid: true))

                    Toggle("Disabled Off", isOn: .constant(false))
                        .toggleStyle(.legendSwitch)
                        .disabled(true)

                    Toggle("Disabled On", isOn: .constant(true))
                        .toggleStyle(.legendSwitch)
                        .disabled(true)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Switch Sizes") {
        struct PreviewContainer: View {
            @State private var sm = true
            @State private var md = true
            @State private var lg = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Small switch", isOn: $sm)
                        .toggleStyle(.legendSwitch(size: .sm))

                    Toggle("Medium switch", isOn: $md)
                        .toggleStyle(.legendSwitch(size: .md))

                    Toggle("Large switch", isOn: $lg)
                        .toggleStyle(.legendSwitch(size: .lg))
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Switch Only (No Label)") {
        struct PreviewContainer: View {
            @State private var toggled = false

            var body: some View {
                HStack(spacing: 16) {
                    Toggle(isOn: $toggled) { EmptyView() }
                        .toggleStyle(.legendSwitch(size: .sm))

                    Toggle(isOn: $toggled) { EmptyView() }
                        .toggleStyle(.legendSwitch(size: .md))

                    Toggle(isOn: $toggled) { EmptyView() }
                        .toggleStyle(.legendSwitch(size: .lg))
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Dark Mode") {
        struct PreviewContainer: View {
            @State private var switch1 = false
            @State private var switch2 = true
            @State private var switch3 = true

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Off", isOn: $switch1)
                        .toggleStyle(.legendSwitch)

                    Toggle("On", isOn: $switch2)
                        .toggleStyle(.legendSwitch)

                    Toggle("Invalid", isOn: $switch3)
                        .toggleStyle(.legendSwitch(isInvalid: true))
                }
                .padding()
                .background(Color("background", bundle: .module))
            }
        }

        return PreviewContainer()
            .preferredColorScheme(.dark)
    }
#endif
