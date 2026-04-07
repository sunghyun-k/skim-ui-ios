import SwiftUI

// MARK: - TextInputStyle

/// A protocol that defines how a text input should be rendered.
///
/// Conform to this protocol to create custom text input styles.
/// Use the provided `TextInputStyleConfiguration` to access all input properties.
@MainActor
public protocol TextInputStyle {
    associatedtype Body: View

    /// Creates the view representing the text input.
    ///
    /// - Parameter configuration: The properties of the text input being styled.
    /// - Returns: A view that represents the styled text input.
    @ViewBuilder
    func makeBody(configuration: TextInputStyleConfiguration) -> Body
}

// MARK: - TextInputStyleConfiguration

/// A configuration object that contains all properties needed to render a text input.
///
/// This struct is passed to `TextInputStyle.makeBody(configuration:)` and contains
/// all the information needed to create a custom text input appearance.
public struct TextInputStyleConfiguration {
    /// The label view displayed above the input field.
    public let label: AnyView?

    /// A binding to the text value of the input.
    public let text: Binding<String>

    /// Placeholder text displayed when the input is empty.
    public let prompt: LocalizedStringResource?

    /// Content displayed at the start of the input field (e.g., an icon).
    public let startContent: AnyView?

    /// Content displayed at the end of the input field (e.g., a button).
    public let endContent: AnyView?

    /// Helper text displayed below the input field.
    public let description: AnyView?

    /// Error message displayed when `isInvalid` is true.
    public let errorMessage: AnyView?

    /// Whether the input is marked as required (displays an asterisk).
    public let isRequired: Bool

    /// Whether the input should mask its content (password field).
    public let isSecure: Bool

    /// Whether the input is in an invalid/error state.
    public let isInvalid: Bool

    /// Whether the input is disabled.
    public let isDisabled: Bool

    /// Whether the input currently has keyboard focus.
    public let isFocused: Bool

    /// Whether the input should support multiple lines of text.
    public let isMultiline: Bool

    /// Creates a new text input style configuration.
    public init(
        label: AnyView?,
        text: Binding<String>,
        prompt: LocalizedStringResource?,
        startContent: AnyView?,
        endContent: AnyView?,
        description: AnyView?,
        errorMessage: AnyView?,
        isRequired: Bool,
        isSecure: Bool,
        isInvalid: Bool,
        isDisabled: Bool,
        isFocused: Bool,
        isMultiline: Bool,
    ) {
        self.label = label
        self.text = text
        self.prompt = prompt
        self.startContent = startContent
        self.endContent = endContent
        self.description = description
        self.errorMessage = errorMessage
        self.isRequired = isRequired
        self.isSecure = isSecure
        self.isInvalid = isInvalid
        self.isDisabled = isDisabled
        self.isFocused = isFocused
        self.isMultiline = isMultiline
    }
}

// MARK: - AnyTextInputStyle (Type Eraser)

/// A type-erased text input style that allows storing different style types uniformly.
///
/// Use `AnyTextInputStyle` when you need to store or pass around text input styles
/// of different concrete types.
@MainActor
public struct AnyTextInputStyle: TextInputStyle {
    private let _makeBody: (TextInputStyleConfiguration) -> AnyView

    /// Creates a type-erased style from any `TextInputStyle` conforming type.
    ///
    /// - Parameter style: The concrete style to wrap.
    public init(_ style: some TextInputStyle) {
        self._makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: TextInputStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}
