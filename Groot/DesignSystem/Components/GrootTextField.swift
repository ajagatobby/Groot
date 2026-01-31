import SwiftUI

// MARK: - Groot Text Field

struct GrootTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let validation: ValidationState
    let onSubmit: (() -> Void)?
    
    enum ValidationState {
        case none
        case valid
        case invalid(String)
        
        var borderColor: Color {
            switch self {
            case .none: return .grootMist
            case .valid: return .grootSuccess
            case .invalid: return .grootError
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .none: return .grootCloud
            case .valid: return .grootSuccessBg
            case .invalid: return .grootErrorBg
            }
        }
    }
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        validation: ValidationState = .none,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.validation = validation
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.system(size: 18, weight: .medium))
                }
                
                if isSecure {
                    SecureField(placeholder.lowercased(), text: $text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                        .keyboardType(keyboardType)
                        .onSubmit { onSubmit?() }
                } else {
                    TextField(placeholder.lowercased(), text: $text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                        .keyboardType(keyboardType)
                        .onSubmit { onSubmit?() }
                }
                
                if !text.isEmpty {
                    Button {
                        withAnimation(.grootSnappy) {
                            text = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.grootPebble)
                            .font(.system(size: 18))
                    }
                }
                
                if case .valid = validation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.grootSuccess)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(validation.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(validation.borderColor, lineWidth: 2)
            )
            .animation(.grootSnappy, value: validation.borderColor)
            
            if case .invalid(let message) = validation {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(message.lowercased())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundStyle(Color.grootError)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var iconColor: Color {
        switch validation {
        case .none:
            return text.isEmpty ? .grootPebble : .grootStone
        case .valid:
            return .grootSuccess
        case .invalid:
            return .grootError
        }
    }
}

// MARK: - Phone Number Field

struct GrootPhoneField: View {
    let placeholder: String
    @Binding var phoneNumber: String
    let countryCode: String
    let countryFlag: String
    let validation: GrootTextField.ValidationState
    let onCountryTap: () -> Void
    
    init(
        _ placeholder: String = "phone number",
        phoneNumber: Binding<String>,
        countryCode: String = "+1",
        countryFlag: String = "🇺🇸",
        validation: GrootTextField.ValidationState = .none,
        onCountryTap: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self._phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.countryFlag = countryFlag
        self.validation = validation
        self.onCountryTap = onCountryTap
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCountryTap) {
                HStack(spacing: 8) {
                    Text(countryFlag)
                        .font(.system(size: 22))
                    
                    Text(countryCode)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.grootStone)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.grootCloud)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.grootMist, lineWidth: 2)
                )
            }
            .sensoryFeedback(.selection, trigger: countryCode)
            
            GrootTextField(
                placeholder,
                text: $phoneNumber,
                icon: "phone.fill",
                keyboardType: .phonePad,
                validation: validation
            )
        }
    }
}

// MARK: - Search Field

struct GrootSearchField: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: (() -> Void)?
    
    init(
        _ placeholder: String = "search",
        text: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        GrootTextField(
            placeholder,
            text: $text,
            icon: "magnifyingglass",
            onSubmit: onSubmit
        )
    }
}

// MARK: - Preview

#Preview("Groot Text Fields") {
    ScrollView {
        VStack(spacing: 24) {
            GrootText("text fields", style: .heading)
            
            VStack(spacing: 16) {
                GrootTextField("enter phone number", text: .constant(""), icon: "phone.fill")
                GrootTextField("search contacts", text: .constant("John"), icon: "magnifyingglass")
                GrootTextField("valid input", text: .constant("1234567890"), icon: "checkmark", validation: .valid)
                GrootTextField("invalid input", text: .constant("abc"), icon: "xmark", validation: .invalid("please enter a valid number"))
            }
            
            GrootText("phone field", style: .heading)
            
            GrootPhoneField(phoneNumber: .constant("5551234567"), countryCode: "+1", countryFlag: "🇺🇸") { }
            GrootPhoneField(phoneNumber: .constant("7890123456"), countryCode: "+44", countryFlag: "🇬🇧") { }
            GrootPhoneField(phoneNumber: .constant(""), countryCode: "+91", countryFlag: "🇮🇳") { }
            
            GrootText("search field", style: .heading)
            
            GrootSearchField(text: .constant(""))
        }
        .padding(20)
    }
    .background(Color.grootSnow)
}
