import SwiftUI

// MARK: - Groot Banner

struct GrootBanner: View {
    let message: String
    let variant: BannerVariant
    let icon: String?
    let action: BannerAction?
    let onDismiss: (() -> Void)?
    
    struct BannerAction {
        let title: String
        let action: () -> Void
    }
    
    enum BannerVariant {
        case success
        case error
        case warning
        case info
        
        var backgroundColor: Color {
            switch self {
            case .success: return .grootSuccessBg
            case .error: return .grootErrorBg
            case .warning: return .grootWarningBg
            case .info: return .grootInfoBg
            }
        }
        
        var iconColor: Color {
            switch self {
            case .success: return .grootSuccess
            case .error: return .grootError
            case .warning: return .grootWarning
            case .info: return .grootInfo
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    init(
        _ message: String,
        variant: BannerVariant,
        icon: String? = nil,
        action: BannerAction? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.variant = variant
        self.icon = icon
        self.action = action
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon ?? variant.defaultIcon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(variant.iconColor)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootBark)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            if let action {
                Button(action: action.action) {
                    Text(action.title.lowercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(variant.iconColor)
                }
            }
            
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.grootStone)
                }
            }
        }
        .padding(16)
        .background(variant.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(variant.iconColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Toast

struct GrootToast: View {
    let message: String
    let variant: GrootBanner.BannerVariant
    let icon: String?
    
    @State private var isVisible = false
    
    init(
        _ message: String,
        variant: GrootBanner.BannerVariant = .success,
        icon: String? = nil
    ) {
        self.message = message
        self.variant = variant
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon ?? variant.defaultIcon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(variant.iconColor)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootBark)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.grootSnow)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0)
        .onAppear {
            withAnimation(.grootBouncy) {
                isVisible = true
            }
        }
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let variant: GrootBanner.BannerVariant
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isPresented {
                    GrootToast(message, variant: variant)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(.grootSmooth) {
                                    isPresented = false
                                }
                            }
                        }
                    
                    Spacer()
                }
            }
            .padding(.top, 60)
        }
    }
}

extension View {
    func grootToast(
        isPresented: Binding<Bool>,
        message: String,
        variant: GrootBanner.BannerVariant = .success,
        duration: TimeInterval = 3.0
    ) -> some View {
        self.modifier(ToastModifier(
            isPresented: isPresented,
            message: message,
            variant: variant,
            duration: duration
        ))
    }
}

// MARK: - Callout

struct GrootCallout: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        icon: String,
        color: Color = .grootSky,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title.lowercased())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                Text(message)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let action {
                    Button(action: action) {
                        Text("learn more")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(color)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Groot Banners") {
    ScrollView {
        VStack(spacing: 24) {
            GrootText("banners", style: .heading)
            
            GrootBanner(
                "Number successfully blocked!",
                variant: .success,
                onDismiss: { }
            )
            
            GrootBanner(
                "Failed to sync block list",
                variant: .error,
                action: .init(title: "retry", action: { }),
                onDismiss: { }
            )
            
            GrootBanner(
                "Your trial expires in 3 days",
                variant: .warning,
                action: .init(title: "upgrade", action: { })
            )
            
            GrootBanner(
                "New blocking features available",
                variant: .info
            )
            
            GrootText("toast", style: .heading)
            
            GrootToast("Call blocked successfully!", variant: .success)
            GrootToast("Number added to whitelist", variant: .info, icon: "checkmark.shield.fill")
            
            GrootText("callout", style: .heading)
            
            GrootCallout(
                title: "enable call blocking",
                message: "Go to Settings → Phone → Call Blocking & Identification to enable Groot.",
                icon: "gearshape.fill",
                color: .grootSky,
                action: { }
            )
            
            GrootCallout(
                title: "protect your privacy",
                message: "Groot never uploads your data. All call blocking happens on your device.",
                icon: "lock.shield.fill",
                color: .grootShield
            )
        }
        .padding(20)
    }
    .background(Color.grootCloud)
}
