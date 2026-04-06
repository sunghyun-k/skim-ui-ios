import SwiftUI

// MARK: - TextInput

/// A customizable text input view that supports various configurations including labels,
/// descriptions, validation states, and custom styling.
///
/// Use `TextInput` to create form fields with consistent styling and behavior.
/// The component automatically handles focus states, disabled states, and validation feedback.
public struct TextInput<Style: TextInputStyle>: View {
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let label: AnyView?
    private let prompt: String?
    private let startContent: AnyView?
    private let endContent: AnyView?
    private let description: AnyView?
    private let errorMessage: AnyView?
    private let isRequired: Bool
    private let isSecure: Bool
    private let isInvalid: Bool
    private let isMultiline: Bool
    private let style: Style

    /// Creates a text input with a custom style and label.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - style: The custom style to apply to the input.
    ///   - label: A view builder for the input label.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        style: Style,
        @ViewBuilder label: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = style
        self.label = AnyView(label())
        self.startContent = nil
        self.endContent = nil
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a custom style, label, and start/end content.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - style: The custom style to apply to the input.
    ///   - label: A view builder for the input label.
    ///   - startContent: A view builder for content displayed at the start of the input (e.g., an
    /// icon).
    ///   - endContent: A view builder for content displayed at the end of the input (e.g., a
    /// button).
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        style: Style,
        @ViewBuilder label: () -> some View,
        @ViewBuilder startContent: () -> some View,
        @ViewBuilder endContent: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = style
        self.label = AnyView(label())
        self.startContent = AnyView(startContent())
        self.endContent = AnyView(endContent())
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a custom style, label, description, and error message.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - style: The custom style to apply to the input.
    ///   - label: A view builder for the input label.
    ///   - description: A view builder for helper text displayed below the input.
    ///   - errorMessage: A view builder for error text displayed when `isInvalid` is true.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        style: Style,
        @ViewBuilder label: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder errorMessage: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = style
        self.label = AnyView(label())
        self.startContent = nil
        self.endContent = nil
        self.description = AnyView(description())
        self.errorMessage = AnyView(errorMessage())
    }

    /// Creates a fully customizable text input with all available options.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - style: The custom style to apply to the input.
    ///   - label: A view builder for the input label.
    ///   - startContent: A view builder for content displayed at the start of the input.
    ///   - endContent: A view builder for content displayed at the end of the input.
    ///   - description: A view builder for helper text displayed below the input.
    ///   - errorMessage: A view builder for error text displayed when `isInvalid` is true.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        style: Style,
        @ViewBuilder label: () -> some View,
        @ViewBuilder startContent: () -> some View,
        @ViewBuilder endContent: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder errorMessage: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = style
        self.label = AnyView(label())
        self.startContent = AnyView(startContent())
        self.endContent = AnyView(endContent())
        self.description = AnyView(description())
        self.errorMessage = AnyView(errorMessage())
    }

    public var body: some View {
        let configuration = TextInputStyleConfiguration(
            label: label,
            text: $text,
            prompt: prompt,
            startContent: startContent,
            endContent: endContent,
            description: description,
            errorMessage: errorMessage,
            isRequired: isRequired,
            isSecure: isSecure,
            isInvalid: isInvalid,
            isDisabled: !isEnabled,
            isFocused: isFocused,
            isMultiline: isMultiline,
        )

        style.makeBody(configuration: configuration)
            .focused($isFocused)
    }
}

// MARK: - Convenience init with default style

/// Convenience initializers that use `DefaultTextInputStyle` for simpler API usage.
extension TextInput where Style == DefaultTextInputStyle {
    /// Creates a text input with a `LocalizedStringResource` label and default styling.
    public init(
        _ label: LocalizedStringResource,
        text: Binding<String>,
        prompt: LocalizedStringResource? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
    ) {
        self.init(
            String(localized: label),
            text: text,
            prompt: prompt.map { String(localized: $0) },
            isRequired: isRequired,
            isSecure: isSecure,
            isInvalid: isInvalid,
            isMultiline: isMultiline,
            size: size,
        )
    }

    /// Creates a text input without a label, using only a localized prompt as placeholder.
    public init(
        text: Binding<String>,
        prompt: LocalizedStringResource,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
    ) {
        _text = text
        self.prompt = String(localized: prompt)
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = nil
        self.startContent = nil
        self.endContent = nil
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input without a label, using only a string prompt as placeholder.
    public init(
        text: Binding<String>,
        prompt: String,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = nil
        self.startContent = nil
        self.endContent = nil
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a string label and default styling.
    ///
    /// - Parameters:
    ///   - label: The label text displayed above the input.
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    public init(
        _ label: String,
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(Text(label))
        self.startContent = nil
        self.endContent = nil
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a string label, description, and error message using default
    /// styling.
    ///
    /// - Parameters:
    ///   - label: The label text displayed above the input.
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - description: Helper text displayed below the input.
    ///   - errorMessage: Error text displayed when `isInvalid` is true.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    public init(
        _ label: String,
        text: Binding<String>,
        prompt: String? = nil,
        description: String,
        errorMessage: String,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(Text(label))
        self.startContent = nil
        self.endContent = nil
        self.description = AnyView(Text(description))
        self.errorMessage = AnyView(Text(errorMessage))
    }

    /// Creates a text input with a custom label view and default styling.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    ///   - label: A view builder for the input label.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
        @ViewBuilder label: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(label())
        self.startContent = nil
        self.endContent = nil
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a custom label, start/end content, and default styling.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    ///   - label: A view builder for the input label.
    ///   - startContent: A view builder for content displayed at the start of the input.
    ///   - endContent: A view builder for content displayed at the end of the input.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
        @ViewBuilder label: () -> some View,
        @ViewBuilder startContent: () -> some View,
        @ViewBuilder endContent: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(label())
        self.startContent = AnyView(startContent())
        self.endContent = AnyView(endContent())
        self.description = nil
        self.errorMessage = nil
    }

    /// Creates a text input with a custom label, description, error message, and default styling.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    ///   - label: A view builder for the input label.
    ///   - description: A view builder for helper text displayed below the input.
    ///   - errorMessage: A view builder for error text displayed when `isInvalid` is true.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
        @ViewBuilder label: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder errorMessage: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(label())
        self.startContent = nil
        self.endContent = nil
        self.description = AnyView(description())
        self.errorMessage = AnyView(errorMessage())
    }

    /// Creates a fully customizable text input with all options and default styling.
    ///
    /// - Parameters:
    ///   - text: A binding to the text value.
    ///   - prompt: Placeholder text displayed when the field is empty.
    ///   - isRequired: Whether to display a required indicator (*) next to the label.
    ///   - isSecure: Whether to mask the input as a password field.
    ///   - isInvalid: Whether to display the input in an error state.
    ///   - isMultiline: Whether to use a multiline text editor instead of a single-line field.
    ///   - size: The size variant of the input. Defaults to `.md`.
    ///   - label: A view builder for the input label.
    ///   - startContent: A view builder for content displayed at the start of the input.
    ///   - endContent: A view builder for content displayed at the end of the input.
    ///   - description: A view builder for helper text displayed below the input.
    ///   - errorMessage: A view builder for error text displayed when `isInvalid` is true.
    public init(
        text: Binding<String>,
        prompt: String? = nil,
        isRequired: Bool = false,
        isSecure: Bool = false,
        isInvalid: Bool = false,
        isMultiline: Bool = false,
        size: TextInputSizeType = .md,
        @ViewBuilder label: () -> some View,
        @ViewBuilder startContent: () -> some View,
        @ViewBuilder endContent: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder errorMessage: () -> some View,
    ) {
        _text = text
        self.prompt = prompt
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isMultiline = isMultiline
        self.style = DefaultTextInputStyle(size: size)
        self.label = AnyView(label())
        self.startContent = AnyView(startContent())
        self.endContent = AnyView(endContent())
        self.description = AnyView(description())
        self.errorMessage = AnyView(errorMessage())
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Basic TextField") {
        struct PreviewContainer: View {
            @State private var email = ""

            var body: some View {
                VStack(spacing: 24) {
                    TextInput(
                        "Email",
                        text: $email,
                        prompt: "Enter your email",
                        isRequired: true,
                    )

                    Text("Value: \(email)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("With Description") {
        struct PreviewContainer: View {
            @State private var email = ""

            var body: some View {
                TextInput(
                    "Email",
                    text: $email,
                    prompt: "Enter your email",
                    description: "We'll never share your email with anyone else.",
                    errorMessage: "Please enter a valid email address",
                    isRequired: true,
                )
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Invalid State") {
        struct PreviewContainer: View {
            @State private var email = "invalid"

            var body: some View {
                TextInput(
                    "Email",
                    text: $email,
                    prompt: "Enter your email",
                    description: "We'll never share your email with anyone else.",
                    errorMessage: "Please enter a valid email address",
                    isRequired: true,
                    isInvalid: true,
                )
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Secure Field (Password)") {
        struct PreviewContainer: View {
            @State private var password = ""

            var body: some View {
                TextInput(
                    "Password",
                    text: $password,
                    prompt: "Enter your password",
                    description: "Must be at least 6 characters",
                    errorMessage: "Password is too short",
                    isRequired: true,
                    isSecure: true,
                )
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Password with Toggle") {
        struct PreviewContainer: View {
            @State private var password = ""
            @State private var isSecure = true

            var body: some View {
                TextInput(
                    text: $password,
                    prompt: "Enter your password",
                    isRequired: true,
                    isSecure: isSecure,
                ) {
                    Text("Password")
                } startContent: {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                } endContent: {
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 14))
                    }
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Multiline") {
        struct PreviewContainer: View {
            @State private var message = ""

            var body: some View {
                TextInput(
                    "Message",
                    text: $message,
                    prompt: "Type your message here...",
                    description: "Maximum 500 characters",
                    errorMessage: "Message is too long",
                    isMultiline: true,
                )
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Sizes") {
        struct PreviewContainer: View {
            @State private var sm = ""
            @State private var md = ""
            @State private var lg = ""

            var body: some View {
                VStack(spacing: 24) {
                    TextInput(
                        "Small",
                        text: $sm,
                        prompt: "Small size",
                        size: .sm,
                    )

                    TextInput(
                        "Medium",
                        text: $md,
                        prompt: "Medium size",
                        size: .md,
                    )

                    TextInput(
                        "Large",
                        text: $lg,
                        prompt: "Large size",
                        size: .lg,
                    )
                }
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Disabled") {
        struct PreviewContainer: View {
            @State private var text = "Disabled value"

            var body: some View {
                TextInput(
                    "Account ID",
                    text: $text,
                    description: "Contact support to change",
                    errorMessage: "",
                )
                .disabled(true)
                .padding()
            }
        }

        return PreviewContainer()
    }

    #Preview("Dark Mode") {
        struct PreviewContainer: View {
            @State private var email = ""
            @State private var password = ""

            var body: some View {
                VStack(spacing: 24) {
                    TextInput(
                        "Email",
                        text: $email,
                        prompt: "Enter your email",
                        description: "We'll never share your email",
                        errorMessage: "Invalid email",
                        isRequired: true,
                    )

                    TextInput(
                        "Password",
                        text: $password,
                        prompt: "Enter your password",
                        description: "Must be at least 6 characters",
                        errorMessage: "Password too short",
                        isRequired: true,
                        isSecure: true,
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
