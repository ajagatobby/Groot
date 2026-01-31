import SwiftUI

// MARK: - Groot Card

struct GrootCard<Content: View>: View {
    let content: Content
    let variant: GrootCardVariant
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    init(
        variant: GrootCardVariant = .standard,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.variant = variant
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(variant.borderColor, lineWidth: variant.hasBorder ? 2 : 0)
            )
            .shadow(
                color: variant.hasShadow ? Color.black.opacity(0.08) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Card Variants

enum GrootCardVariant {
    case standard
    case elevated
    case flat
    case success
    case error
    case warning
    case info
    
    var backgroundColor: Color {
        switch self {
        case .standard, .elevated, .flat:
            return .grootSnow
        case .success:
            return .grootSuccessBg
        case .error:
            return .grootErrorBg
        case .warning:
            return .grootWarningBg
        case .info:
            return .grootInfoBg
        }
    }
    
    var borderColor: Color {
        switch self {
        case .standard, .elevated:
            return .clear
        case .flat:
            return .grootMist
        case .success:
            return .grootSuccess
        case .error:
            return .grootError
        case .warning:
            return .grootWarning
        case .info:
            return .grootInfo
        }
    }
    
    var hasBorder: Bool {
        switch self {
        case .flat, .success, .error, .warning, .info:
            return true
        default:
            return false
        }
    }
    
    var hasShadow: Bool {
        switch self {
        case .standard:
            return true
        case .elevated:
            return true
        default:
            return false
        }
    }
}

// MARK: - Pressable Card

struct GrootPressableCard<Content: View>: View {
    let content: Content
    let variant: GrootCardVariant
    let padding: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        variant: GrootCardVariant = .standard,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.variant = variant
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(padding)
                .background(variant.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(variant.borderColor, lineWidth: variant.hasBorder ? 2 : 0)
                )
                .shadow(
                    color: variant.hasShadow ? Color.black.opacity(0.08) : .clear,
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.grootSnappy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.grootSnappy) {
                        isPressed = false
                    }
                }
        )
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.3), trigger: isPressed)
    }
}

// MARK: - Selectable Card

struct GrootSelectableCard<Content: View>: View {
    let content: Content
    let isSelected: Bool
    let padding: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(
        isSelected: Bool,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isSelected = isSelected
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(padding)
                .background(isSelected ? Color.grootInfoBg : Color.grootSnow)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isSelected ? Color.grootSky : Color.grootMist, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.grootSnappy, value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Stats Card

struct GrootStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String?
    
    init(
        title: String,
        value: String,
        icon: String,
        color: Color = .grootShield,
        subtitle: String? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        GrootCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(color)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text(title.lowercased())
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                    
                    if let subtitle {
                        Text(subtitle.lowercased())
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(color)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Groot Cards") {
    ScrollView {
        VStack(spacing: 20) {
            GrootText("card variants", style: .heading)
            
            GrootCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        GrootText("standard card", style: .subheading)
                        GrootText("With shadow and rounded corners", style: .bodySmall)
                    }
                    Spacer()
                }
            }
            
            GrootCard(variant: .flat) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        GrootText("flat card", style: .subheading)
                        GrootText("Border only, no shadow", style: .bodySmall)
                    }
                    Spacer()
                }
            }
            
            GrootCard(variant: .success) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.grootSuccess)
                    GrootText("Success card", style: .subheading)
                    Spacer()
                }
            }
            
            GrootCard(variant: .error) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.grootError)
                    GrootText("Error card", style: .subheading)
                    Spacer()
                }
            }
            
            GrootText("stats cards", style: .heading)
            
            HStack(spacing: 12) {
                GrootStatsCard(
                    title: "blocked",
                    value: "127",
                    icon: "hand.raised.fill",
                    color: .grootFlame
                )
                
                GrootStatsCard(
                    title: "allowed",
                    value: "42",
                    icon: "checkmark.shield.fill",
                    color: .grootShield
                )
            }
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
