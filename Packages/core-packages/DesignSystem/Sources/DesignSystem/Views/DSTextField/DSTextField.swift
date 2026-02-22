import SwiftUI

/// Visual style for DSTextField.
public enum DSTextFieldStyle {
    /// Bordered style with rounded corners and full border.
    case bordered
    /// Minimal style with only an underline.
    case underline
}

/// A styled text field following the design system.
/// Supports icons, placeholder text, and various keyboard types.
public struct DSTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    let isSecure: Bool
    let isError: Bool
    let errorMessage: String?
    let style: DSTextFieldStyle

    @FocusState private var isFocused: Bool

    public init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        isSecure: Bool = false,
        isError: Bool = false,
        errorMessage: String? = nil,
        style: DSTextFieldStyle = .bordered
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.isSecure = isSecure
        self.isError = isError
        self.errorMessage = errorMessage
        self.style = style
    }

    public var body: some View {
        switch style {
        case .bordered:
            borderedStyle
        case .underline:
            underlineStyle
        }
    }

    private var iconColor: Color {
        if isError { return .error }
        if isFocused { return .themePrimary }
        return .textTertiary
    }

    private var fieldContent: some View {
        HStack(spacing: DSSpacing.smd) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: DSLayout.iconXS, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 20)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(autocapitalization)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .focused($isFocused)
            }
        }
        .font(.bodyMedium())
        .foregroundStyle(Color.textPrimary)
        .tint(Color.themePrimary)
    }

    private var borderedStyle: some View {
        let shape = RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)

        return VStack(alignment: .leading, spacing: DSSpacing.xs) {
            fieldContent
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.smd)
                .frame(minHeight: 48)
                .background(isFocused ? Color.themePrimary.opacity(0.06) : Color.surfaceVariant)
                .clipShape(shape)
                .shadow(
                    color: isFocused ? Color.themePrimary.opacity(0.12) : .clear,
                    radius: 8,
                    x: 0,
                    y: 2
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .animation(.easeInOut(duration: 0.15), value: isError)

            if let errorMessage, isError {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                    Text(errorMessage)
                        .font(.captionLarge())
                }
                .foregroundStyle(Color.error)
                .padding(.leading, DSSpacing.xs)
            }
        }
    }

    private var isActive: Bool {
        isFocused || !text.isEmpty
    }

    private var underlineStyle: some View {
        VStack(alignment: .leading, spacing: 0) {
            fieldContent
                .padding(.vertical, DSSpacing.smd)
                .frame(height: 44)

            Rectangle()
                .fill(isActive ? Color.themePrimary : Color.border)
                .frame(height: isActive ? 2 : 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Convenience Initializers

public extension DSTextField {
    /// Creates a simple text field without icon.
    static func simple(
        placeholder: String,
        text: Binding<String>
    ) -> DSTextField {
        DSTextField(
            placeholder: placeholder,
            text: text
        )
    }

    /// Creates an email text field with envelope icon.
    static func email(
        placeholder: String = "Email",
        text: Binding<String>
    ) -> DSTextField {
        DSTextField(
            placeholder: placeholder,
            text: text,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
    }

    /// Creates a password text field with lock icon.
    static func password(
        placeholder: String = "Password",
        text: Binding<String>
    ) -> DSTextField {
        DSTextField(
            placeholder: placeholder,
            text: text,
            icon: "lock",
            autocapitalization: .never,
            isSecure: true
        )
    }

    /// Creates a name text field with person icon.
    static func name(
        placeholder: String = "Name",
        text: Binding<String>
    ) -> DSTextField {
        DSTextField(
            placeholder: placeholder,
            text: text,
            icon: "person",
            autocapitalization: .words
        )
    }
}

// MARK: - Previews

#Preview("Basic") {
    VStack(spacing: DSSpacing.md) {
        DSTextField(
            placeholder: "Enter text",
            text: .constant("")
        )

        DSTextField(
            placeholder: "With value",
            text: .constant("Hello World")
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("With Icons") {
    VStack(spacing: DSSpacing.md) {
        DSTextField(
            placeholder: "Your name",
            text: .constant(""),
            icon: "person"
        )

        DSTextField(
            placeholder: "Email address",
            text: .constant(""),
            icon: "envelope",
            keyboardType: .emailAddress
        )

        DSTextField(
            placeholder: "Phone number",
            text: .constant(""),
            icon: "phone",
            keyboardType: .phonePad
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Convenience Initializers") {
    VStack(spacing: DSSpacing.md) {
        DSTextField.simple(
            placeholder: "Simple field",
            text: .constant("")
        )

        DSTextField.name(
            text: .constant("")
        )

        DSTextField.email(
            text: .constant("")
        )

        DSTextField.password(
            text: .constant("")
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Dark Mode") {
    VStack(spacing: DSSpacing.md) {
        DSTextField(
            placeholder: "Enter text",
            text: .constant(""),
            icon: "magnifyingglass"
        )

        DSTextField.email(
            text: .constant("user@example.com")
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Underline Style") {
    VStack(spacing: DSSpacing.lg) {
        DSTextField(
            placeholder: "Enter your name",
            text: .constant(""),
            icon: "person",
            style: .underline
        )

        DSTextField(
            placeholder: "Email address",
            text: .constant("hello@example.com"),
            icon: "envelope",
            style: .underline
        )

        DSTextField(
            placeholder: "No icon",
            text: .constant(""),
            style: .underline
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Underline Style - Dark") {
    VStack(spacing: DSSpacing.lg) {
        DSTextField(
            placeholder: "Type something",
            text: .constant(""),
            style: .underline
        )

        DSTextField(
            placeholder: "With value",
            text: .constant("Hello"),
            style: .underline
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
