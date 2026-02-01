import SwiftUI

// MARK: - Groot Button

struct GrootButton: View {
    let title: String
    let variant: GrootButtonVariant
    let size: GrootButtonSize
    let icon: String?
    let iconPosition: IconPosition
    let isFullWidth: Bool
    let isDisabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    enum IconPosition {
        case leading
        case trailing
    }
    
    init(
        _ title: String,
        variant: GrootButtonVariant = .primary,
        size: GrootButtonSize = .large,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        isFullWidth: Bool = true,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.icon = icon
        self.iconPosition = iconPosition
        self.isFullWidth = isFullWidth
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: colors.foreground))
                        .scaleEffect(0.8)
                } else {
                    if let icon, iconPosition == .leading {
                        Image(systemName: icon)
                            .font(.system(size: size.iconSize, weight: .bold))
                    }
                    
                    Text(title.lowercased())
                        .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    
                    if let icon, iconPosition == .trailing {
                        Image(systemName: icon)
                            .font(.system(size: size.iconSize, weight: .bold))
                    }
                }
            }
            .foregroundStyle(colors.foreground)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
        }
        .buttonStyle(GrootButtonStyle(
            backgroundColor: colors.background,
            shadowColor: colors.shadow,
            cornerRadius: size.cornerRadius,
            isDisabled: isDisabled || isLoading
        ))
        .disabled(isDisabled || isLoading)
    }
    
    private var colors: GrootButtonColors {
        if isDisabled {
            return .disabled
        }
        return variant.colors
    }
}

// MARK: - Button Style

struct GrootButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let shadowColor: Color
    let cornerRadius: CGFloat
    let shadowOffset: CGFloat = 4
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .offset(y: configuration.isPressed && !isDisabled ? shadowOffset : 0)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .offset(y: shadowOffset)
                    .opacity(configuration.isPressed || isDisabled ? 0 : 1)
            )
            .animation(.grootSnappy, value: configuration.isPressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: configuration.isPressed)
    }
}

// MARK: - Button Variants

enum GrootButtonVariant {
    case primary
    case secondary
    case danger
    case warning
    case premium
    case ghost
    
    var colors: GrootButtonColors {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        case .danger: return .danger
        case .warning: return .warning
        case .premium: return .premium
        case .ghost: return GrootButtonColors(
            background: .clear,
            shadow: .clear,
            foreground: .grootSky
        )
        }
    }
}

// MARK: - Button Sizes

enum GrootButtonSize {
    case small
    case medium
    case large
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 14
        case .large: return 18
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }
}

// MARK: - Icon Button

struct GrootIconButton: View {
    let icon: String
    let variant: GrootButtonVariant
    let size: GrootIconButtonSize
    let action: () -> Void
    
    enum GrootIconButtonSize {
        case small
        case medium
        case large
        
        var tapSize: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 28
            }
        }
    }
    
    init(
        _ icon: String,
        variant: GrootButtonVariant = .secondary,
        size: GrootIconButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.variant = variant
        self.size = size
        self.action = action
    }
    
    private var iconColor: Color {
        switch variant {
        case .primary: return .grootShield
        case .secondary: return .grootStone
        case .danger: return .grootFlame
        case .warning: return .grootSun
        case .ghost: return .grootStone
        case .premium: return .grootSun
        }
    }
    
    var body: some View {
        Button {
            GrootHaptics.selection()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: size.tapSize, height: size.tapSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(IconButtonStyle())
    }
}

// MARK: - Icon Button Style

private struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Groot Buttons") {
    ScrollView {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                GrootText("primary buttons", style: .heading)
                
                GrootButton("block number", icon: "hand.raised.fill") { }
                GrootButton("add to whitelist", variant: .secondary, icon: "checkmark.shield.fill") { }
                GrootButton("delete", variant: .danger, icon: "trash.fill") { }
                GrootButton("upgrade", variant: .premium, icon: "crown.fill") { }
            }
            
            VStack(spacing: 12) {
                GrootText("button sizes", style: .heading)
                
                GrootButton("large button", size: .large) { }
                GrootButton("medium button", size: .medium) { }
                GrootButton("small button", size: .small) { }
            }
            
            VStack(spacing: 12) {
                GrootText("button states", style: .heading)
                
                GrootButton("disabled", isDisabled: true) { }
                GrootButton("loading", isLoading: true) { }
            }
            
            VStack(spacing: 12) {
                GrootText("icon buttons", style: .heading)
                
                HStack(spacing: 12) {
                    GrootIconButton("plus", variant: .primary) { }
                    GrootIconButton("gearshape.fill", variant: .secondary) { }
                    GrootIconButton("trash.fill", variant: .danger) { }
                    GrootIconButton("crown.fill", variant: .premium) { }
                }
            }
        }
        .padding(20)
    }
    .background(Color.grootSnow)
}
