import SwiftUI

// MARK: - Fluid Modal Animation

extension Animation {
    /// Fluid modal entrance - bouncy with overshoot
    static let modalEnter = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
    
    /// Fluid modal exit - quick and smooth
    static let modalExit = Animation.spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0)
    
    /// Overlay fade
    static let overlayFade = Animation.easeOut(duration: 0.25)
    
    /// Content stagger base
    static func stagger(_ index: Int) -> Animation {
        .spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05)
    }
}

// MARK: - Groot Modal

struct GrootModal<Content: View>: View {
    @Binding var isPresented: Bool
    let position: ModalPosition
    let overlayStyle: OverlayStyle
    let dismissOnBackgroundTap: Bool
    let content: Content
    
    @State private var contentVisible = false
    @State private var overlayOpacity: Double = 0
    
    enum ModalPosition {
        case center
        case bottom
        case top
    }
    
    enum OverlayStyle {
        case dimmed
        case blurred
        case dimmedBlur
        case none
    }
    
    init(
        isPresented: Binding<Bool>,
        position: ModalPosition = .center,
        overlayStyle: OverlayStyle = .dimmed,
        dismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.position = position
        self.overlayStyle = overlayStyle
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                overlayView
                    .opacity(overlayOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnBackgroundTap {
                            dismissModal()
                        }
                    }
                
                modalContent
                    .opacity(contentVisible ? 1 : 0)
                    .scaleEffect(contentScale)
                    .offset(y: contentOffset)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                showModal()
            }
        }
    }
    
    private var contentScale: CGFloat {
        guard position == .center else { return 1 }
        return contentVisible ? 1 : 0.85
    }
    
    private var contentOffset: CGFloat {
        switch position {
        case .center:
            return contentVisible ? 0 : 30
        case .bottom:
            return contentVisible ? 0 : 300
        case .top:
            return contentVisible ? 0 : -300
        }
    }
    
    private func showModal() {
        withAnimation(.overlayFade) {
            overlayOpacity = 1
        }
        withAnimation(.modalEnter.delay(0.05)) {
            contentVisible = true
        }
        GrootHaptics.buttonPress()
    }
    
    private func dismissModal() {
        withAnimation(.modalExit) {
            contentVisible = false
        }
        withAnimation(.overlayFade.delay(0.1)) {
            overlayOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isPresented = false
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch overlayStyle {
        case .dimmed:
            Color.black.opacity(0.5)
        case .blurred:
            Rectangle()
                .fill(.ultraThinMaterial)
        case .dimmedBlur:
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.25))
        case .none:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var modalContent: some View {
        VStack {
            switch position {
            case .top:
                content
                    .padding(.top, 60)
                Spacer()
            case .center:
                Spacer()
                content
                Spacer()
            case .bottom:
                Spacer()
                content
                    .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Modal Content with Staggered Animation

struct GrootModalContent<Actions: View>: View {
    let title: String
    let message: String?
    let icon: String?
    let iconColor: Color
    let variant: ModalVariant
    let showCloseButton: Bool
    let actions: Actions
    let onClose: (() -> Void)?
    
    @State private var iconScale: CGFloat = 0.3
    @State private var iconRotation: Double = -30
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 15
    @State private var messageOpacity: Double = 0
    @State private var messageOffset: CGFloat = 15
    @State private var actionsOpacity: Double = 0
    @State private var actionsOffset: CGFloat = 20
    @State private var closeButtonOpacity: Double = 0
    
    enum ModalVariant {
        case standard
        case success
        case error
        case warning
        case info
        
        var iconBackgroundColor: Color {
            switch self {
            case .standard: return .grootCloud
            case .success: return .grootSuccessBg
            case .error: return .grootErrorBg
            case .warning: return .grootWarningBg
            case .info: return .grootInfoBg
            }
        }
        
        var accentColor: Color {
            switch self {
            case .standard: return .grootShield
            case .success: return .grootSuccess
            case .error: return .grootError
            case .warning: return .grootWarning
            case .info: return .grootInfo
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .standard: return "sparkles"
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    init(
        title: String,
        message: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        variant: ModalVariant = .standard,
        showCloseButton: Bool = true,
        onClose: (() -> Void)? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.iconColor = iconColor ?? variant.accentColor
        self.variant = variant
        self.showCloseButton = showCloseButton
        self.onClose = onClose
        self.actions = actions()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showCloseButton {
                HStack {
                    Spacer()
                    Button {
                        onClose?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.grootStone)
                            .frame(width: 32, height: 32)
                            .background(Color.grootCloud)
                            .clipShape(Circle())
                    }
                    .opacity(closeButtonOpacity)
                }
            }
            
            ZStack {
                Circle()
                    .fill(variant.iconBackgroundColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon ?? variant.defaultIcon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .scaleEffect(iconScale)
            .rotationEffect(.degrees(iconRotation))
            
            VStack(spacing: 10) {
                Text(title.lowercased())
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                
                if let message {
                    Text(message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(messageOpacity)
                        .offset(y: messageOffset)
                }
            }
            
            actions
                .opacity(actionsOpacity)
                .offset(y: actionsOffset)
        }
        .padding(24)
        .frame(maxWidth: 340)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.black.opacity(0.12), radius: 30, x: 0, y: 15)
        .onAppear {
            animateContent()
        }
    }
    
    private func animateContent() {
        // Icon bounces in with rotation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
            iconScale = 1.0
            iconRotation = 0
        }
        
        // Close button fades in
        withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
            closeButtonOpacity = 1
        }
        
        // Title slides up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.2)) {
            titleOpacity = 1
            titleOffset = 0
        }
        
        // Message slides up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.3)) {
            messageOpacity = 1
            messageOffset = 0
        }
        
        // Actions slide up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.4)) {
            actionsOpacity = 1
            actionsOffset = 0
        }
    }
}

// MARK: - Convenience Init without Actions

extension GrootModalContent where Actions == EmptyView {
    init(
        title: String,
        message: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        variant: ModalVariant = .standard,
        showCloseButton: Bool = true,
        onClose: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            message: message,
            icon: icon,
            iconColor: iconColor,
            variant: variant,
            showCloseButton: showCloseButton,
            onClose: onClose
        ) {
            EmptyView()
        }
    }
}

// MARK: - Alert Modal

struct GrootAlertModal: View {
    let title: String
    let message: String
    let icon: String?
    let variant: GrootModalContent<EmptyView>.ModalVariant
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    struct AlertButton {
        let title: String
        let variant: GrootButtonVariant
        let action: () -> Void
        
        static func primary(_ title: String, action: @escaping () -> Void) -> AlertButton {
            AlertButton(title: title, variant: .primary, action: action)
        }
        
        static func secondary(_ title: String, action: @escaping () -> Void) -> AlertButton {
            AlertButton(title: title, variant: .secondary, action: action)
        }
        
        static func danger(_ title: String, action: @escaping () -> Void) -> AlertButton {
            AlertButton(title: title, variant: .danger, action: action)
        }
        
        static func cancel(_ title: String = "cancel", action: @escaping () -> Void) -> AlertButton {
            AlertButton(title: title, variant: .ghost, action: action)
        }
    }
    
    var body: some View {
        GrootModalContent(
            title: title,
            message: message,
            icon: icon,
            variant: variant,
            showCloseButton: false
        ) {
            VStack(spacing: 12) {
                GrootButton(primaryButton.title, variant: primaryButton.variant) {
                    primaryButton.action()
                }
                
                if let secondary = secondaryButton {
                    GrootButton(secondary.title, variant: secondary.variant) {
                        secondary.action()
                    }
                }
            }
        }
    }
}

// MARK: - Floating Action Modal (Bottom Sheet Style)

struct GrootFloatingSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String?
    let showHandle: Bool
    let content: Content
    
    @State private var dragOffset: CGFloat = 0
    @State private var sheetVisible = false
    @State private var overlayOpacity: Double = 0
    @GestureState private var isDragging = false
    
    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        showHandle: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.showHandle = showHandle
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black
                    .opacity(overlayOpacity * 0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                
                sheetContent
                    .offset(y: sheetVisible ? dragOffset : 400)
                    .gesture(dragGesture)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                showSheet()
            }
        }
    }
    
    private var sheetContent: some View {
        VStack(spacing: 0) {
            if showHandle {
                handleView
            }
            
            if let title {
                Text(title.lowercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                
                Divider()
            }
            
            content
        }
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
    
    private var handleView: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.grootMist)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                // Rubber band effect - more resistance as you pull up
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                } else {
                    // Rubber band when pulling up
                    dragOffset = value.translation.height * 0.3
                }
            }
            .onEnded { value in
                let velocity = value.velocity.height
                let translation = value.translation.height
                
                // Dismiss if pulled down enough or with enough velocity
                if translation > 100 || velocity > 800 {
                    dismiss()
                } else {
                    // Snap back with bounce
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    private func showSheet() {
        withAnimation(.easeOut(duration: 0.2)) {
            overlayOpacity = 1
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05)) {
            sheetVisible = true
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            sheetVisible = false
            dragOffset = 0
        }
        withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
            overlayOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isPresented = false
        }
    }
}

// MARK: - Success Modal with Particle Effects

struct GrootSuccessModal: View {
    let title: String
    let message: String?
    let buttonTitle: String
    let action: () -> Void
    
    @State private var ringScale: CGFloat = 0
    @State private var ringOpacity: Double = 1
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = -45
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var color: Color
    }
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Expanding ring
                Circle()
                    .stroke(Color.grootSuccess.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
                
                // Background circle
                Circle()
                    .fill(Color.grootSuccessBg)
                    .frame(width: 100, height: 100)
                    .scaleEffect(checkmarkScale)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.grootSuccess)
                    .scaleEffect(checkmarkScale)
                    .rotationEffect(.degrees(checkmarkRotation))
                
                // Particles
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .offset(x: particle.x, y: particle.y)
                }
            }
            .frame(height: 120)
            
            VStack(spacing: 10) {
                Text(title.lowercased())
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                if let message {
                    Text(message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .multilineTextAlignment(.center)
                }
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
            
            GrootButton(buttonTitle, variant: .primary) {
                action()
            }
            .opacity(buttonOpacity)
            .offset(y: buttonOffset)
        }
        .padding(32)
        .frame(maxWidth: 340)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.black.opacity(0.12), radius: 30, x: 0, y: 15)
        .onAppear {
            animateSuccess()
        }
    }
    
    private func animateSuccess() {
        // Haptic burst
        GrootHaptics.success()
        
        // Ring expands and fades
        withAnimation(.easeOut(duration: 0.6)) {
            ringScale = 1.5
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
            ringOpacity = 0
        }
        
        // Checkmark bounces in with rotation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.1)) {
            checkmarkScale = 1.0
            checkmarkRotation = 0
        }
        
        // Generate particles
        generateParticles()
        
        // Content fades in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35)) {
            contentOpacity = 1
            contentOffset = 0
        }
        
        // Button fades in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            buttonOpacity = 1
            buttonOffset = 0
        }
    }
    
    private func generateParticles() {
        let colors: [Color] = [.grootSuccess, .grootLeaf, .grootSky, .grootSun]
        
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0)
            let radians = angle * .pi / 180
            
            var particle = Particle(
                x: 0,
                y: 0,
                scale: 0,
                opacity: 1,
                color: colors[i % colors.count]
            )
            particles.append(particle)
            
            let index = particles.count - 1
            let distance: CGFloat = CGFloat.random(in: 60...90)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.15 + Double(i) * 0.02)) {
                particles[index].x = cos(radians) * distance
                particles[index].y = sin(radians) * distance
                particles[index].scale = CGFloat.random(in: 0.8...1.2)
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(0.5 + Double(i) * 0.02)) {
                particles[index].opacity = 0
            }
        }
    }
}

// MARK: - View Modifier

extension View {
    func grootModal<Content: View>(
        isPresented: Binding<Bool>,
        position: GrootModal<Content>.ModalPosition = .center,
        overlayStyle: GrootModal<Content>.OverlayStyle = .dimmed,
        dismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            
            GrootModal(
                isPresented: isPresented,
                position: position,
                overlayStyle: overlayStyle,
                dismissOnBackgroundTap: dismissOnBackgroundTap,
                content: content
            )
        }
    }
    
    func grootAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        icon: String? = nil,
        variant: GrootModalContent<EmptyView>.ModalVariant = .standard,
        primaryButton: GrootAlertModal.AlertButton,
        secondaryButton: GrootAlertModal.AlertButton? = nil
    ) -> some View {
        grootModal(isPresented: isPresented) {
            GrootAlertModal(
                title: title,
                message: message,
                icon: icon,
                variant: variant,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        }
    }
    
    func grootFloatingSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            
            GrootFloatingSheet(
                isPresented: isPresented,
                title: title,
                content: content
            )
        }
    }
    
    func grootSuccessModal(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        buttonTitle: String = "done",
        action: @escaping () -> Void
    ) -> some View {
        grootModal(isPresented: isPresented, dismissOnBackgroundTap: false) {
            GrootSuccessModal(
                title: title,
                message: message,
                buttonTitle: buttonTitle,
                action: action
            )
        }
    }
}

// MARK: - Preview

#Preview("Groot Modals") {
    ModalPreviewContainer()
}

private struct ModalPreviewContainer: View {
    @State private var showCenterModal = false
    @State private var showBottomModal = false
    @State private var showAlert = false
    @State private var showSuccess = false
    @State private var showFloatingSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GrootText("modal types", style: .heading)
                
                GrootButton("center modal", variant: .primary) {
                    showCenterModal = true
                }
                
                GrootButton("bottom modal", variant: .secondary) {
                    showBottomModal = true
                }
                
                GrootButton("alert dialog", variant: .danger) {
                    showAlert = true
                }
                
                GrootButton("success modal", variant: .primary, icon: "checkmark") {
                    showSuccess = true
                }
                
                GrootButton("floating sheet", variant: .secondary) {
                    showFloatingSheet = true
                }
            }
            .padding(20)
        }
        .background(Color.grootCloud)
        .grootModal(isPresented: $showCenterModal) {
            GrootModalContent(
                title: "block this number?",
                message: "You won't receive any calls from +1 (555) 123-4567 after blocking.",
                icon: "hand.raised.fill",
                iconColor: .grootFlame,
                variant: .standard,
                onClose: { showCenterModal = false }
            ) {
                VStack(spacing: 12) {
                    GrootButton("block number", variant: .danger) {
                        showCenterModal = false
                    }
                    GrootButton("cancel", variant: .ghost) {
                        showCenterModal = false
                    }
                }
            }
        }
        .grootModal(isPresented: $showBottomModal, position: .bottom) {
            GrootModalContent(
                title: "choose action",
                icon: "ellipsis.circle.fill",
                iconColor: .grootSky,
                showCloseButton: false,
                onClose: { showBottomModal = false }
            ) {
                VStack(spacing: 12) {
                    GrootButton("add to whitelist", variant: .primary, icon: "checkmark.shield") {
                        showBottomModal = false
                    }
                    GrootButton("block number", variant: .danger, icon: "hand.raised") {
                        showBottomModal = false
                    }
                    GrootButton("cancel", variant: .ghost) {
                        showBottomModal = false
                    }
                }
            }
        }
        .grootAlert(
            isPresented: $showAlert,
            title: "delete all blocked numbers?",
            message: "This will remove all 127 blocked numbers. This action cannot be undone.",
            icon: "trash.fill",
            variant: .error,
            primaryButton: .danger("delete all") {
                showAlert = false
            },
            secondaryButton: .cancel {
                showAlert = false
            }
        )
        .grootSuccessModal(
            isPresented: $showSuccess,
            title: "number blocked!",
            message: "You won't receive calls from this number anymore.",
            buttonTitle: "done"
        ) {
            showSuccess = false
        }
        .grootFloatingSheet(isPresented: $showFloatingSheet, title: "quick actions") {
            VStack(spacing: 0) {
                ForEach(["Block Number", "Add to Whitelist", "Report Spam"], id: \.self) { action in
                    Button {
                        showFloatingSheet = false
                    } label: {
                        HStack {
                            Text(action.lowercased())
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.grootBark)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.grootPebble)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    if action != "Report Spam" {
                        Divider().padding(.leading, 20)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}
