import SwiftUI

// MARK: - DefaultTextInputStyle

/// The default text input style that adapts to the current theme.
///
/// This style provides a bordered input field with label, description, and error message support.
/// It automatically handles focus, disabled, and invalid states with appropriate visual feedback.
public struct DefaultTextInputStyle: TextInputStyle {
    private let sizeType: TextInputSizeType

    /// Creates a default text input style with the specified size.
    ///
    /// - Parameter size: The size variant to use. Defaults to `.md`.
    public init(size: TextInputSizeType = .md) {
        self.sizeType = size
    }

    public func makeBody(configuration: TextInputStyleConfiguration) -> some View {
        DefaultTextInputStyleView(
            configuration: configuration,
            sizeType: sizeType,
        )
    }
}

// MARK: - DefaultTextInputStyleView

private struct DefaultTextInputStyleView: View {
    @Environment(\.legendTheme) private var theme

    let configuration: TextInputStyleConfiguration
    let sizeType: TextInputSizeType

    private var size: TextInputSize {
        .resolved(sizeType, layout: theme.layout, typography: theme.typography)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: size.spacing) {
            // Label
            if let label = configuration.label {
                HStack(spacing: 2) {
                    label
                        .fontStyle(size.labelFontStyle)
                        .foregroundStyle(labelColor)

                    if configuration.isRequired {
                        Text("*")
                            .fontStyle(size.labelFontStyle)
                            .foregroundStyle(theme.colors.danger.default)
                    }
                }
                .padding(.horizontal, 4)
            }

            // Input Container
            InputContainerView(
                configuration: configuration,
                size: size,
                theme: theme,
            )

            // Description or Error Message
            if configuration.isInvalid, let errorMessage = configuration.errorMessage {
                errorMessage
                    .fontStyle(size.descriptionFontStyle)
                    .foregroundStyle(theme.colors.danger.default)
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if let description = configuration.description {
                description
                    .fontStyle(size.descriptionFontStyle)
                    .foregroundStyle(theme.colors.foreground.muted)
                    .padding(.horizontal, 4)
            }
        }
        .opacity(configuration.isDisabled ? theme.layout.opacity.disabled : 1)
        .animation(.easeInOut(duration: 0.2), value: configuration.isInvalid)
        .animation(.easeInOut(duration: 0.2), value: configuration.isFocused)
    }

    private var labelColor: Color {
        if configuration.isInvalid {
            return theme.colors.danger.default
        }
        return theme.colors.foreground.primary
    }
}

// MARK: - InputContainerView

private struct InputContainerView: View {
    let configuration: TextInputStyleConfiguration
    let size: TextInputSize
    let theme: LegendTheme

    var body: some View {
        HStack(spacing: size.spacing) {
            if let startContent = configuration.startContent {
                startContent
                    .foregroundStyle(theme.colors.foreground.muted)
            }

            textField

            if let endContent = configuration.endContent {
                endContent
                    .foregroundStyle(theme.colors.foreground.muted)
            }
        }
        .padding(.horizontal, size.horizontalPadding)
        .frame(height: configuration.isMultiline ? nil : size.height)
        .frame(minHeight: configuration.isMultiline ? size.height * 2.5 : nil)
        .padding(.vertical, configuration.isMultiline ? size.verticalPadding : 0)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: size.borderWidth)
        }
    }

    @ViewBuilder
    private var textField: some View {
        if configuration.isSecure {
            SecureField(
                "",
                text: configuration.text,
                prompt: configuration.prompt
                    .map { Text($0).foregroundStyle(theme.colors.foreground.muted) },
            )
            .textFieldStyle(.plain)
            .fontStyle(size.inputFontStyle)
            .foregroundStyle(theme.colors.foreground.primary)
        } else if configuration.isMultiline {
            TextEditor(text: configuration.text)
                .scrollContentBackground(.hidden)
                .fontStyle(size.inputFontStyle)
                .foregroundStyle(theme.colors.foreground.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            #if os(macOS)
                .padding(.vertical, 5)
            #endif
                .overlay(alignment: .topLeading) {
                    if configuration.text.wrappedValue.isEmpty, let prompt = configuration.prompt {
                        Text(prompt)
                            .fontStyle(size.inputFontStyle)
                            .foregroundStyle(theme.colors.foreground.muted)
                            .padding(.leading, 5)
                        #if os(macOS)
                            .padding(.top, 5)
                        #else
                            .padding(.top, 9)
                        #endif
                            .allowsHitTesting(false)
                    }
                }
        } else {
            TextField(
                "",
                text: configuration.text,
                prompt: configuration.prompt
                    .map { Text($0).foregroundStyle(theme.colors.foreground.muted) },
            )
            .textFieldStyle(.plain)
            .fontStyle(size.inputFontStyle)
            .foregroundStyle(theme.colors.foreground.primary)
        }
    }

    private var backgroundColor: Color {
        if configuration.isFocused {
            return theme.colors.surface.secondary
        }
        return theme.colors.surface.primary
    }

    private var borderColor: Color {
        if configuration.isInvalid {
            return theme.colors.danger.default
        }
        if configuration.isFocused {
            return theme.colors.accent.default
        }
        return theme.colors.border
    }
}

// MARK: - Style Extension

/// Convenience accessors for the default text input style.
extension TextInputStyle where Self == DefaultTextInputStyle {
    /// The default text input style with medium size.
    public static var `default`: DefaultTextInputStyle {
        DefaultTextInputStyle()
    }

    /// Creates a default text input style with the specified size.
    ///
    /// - Parameter size: The size variant to use.
    /// - Returns: A configured `DefaultTextInputStyle` instance.
    public static func `default`(size: TextInputSizeType) -> DefaultTextInputStyle {
        DefaultTextInputStyle(size: size)
    }
}
