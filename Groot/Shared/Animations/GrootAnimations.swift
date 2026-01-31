import SwiftUI

// MARK: - Groot Animation Presets

extension Animation {
    
    /// Bouncy animation for success states and celebrations
    /// Use for: Blocking success, achievements, celebrations
    static let grootBouncy = Animation.spring(response: 0.5, dampingFraction: 0.5)
    
    /// Quick, snappy response for button presses
    /// Use for: Button press/release, toggles, quick selections
    static let grootSnappy = Animation.spring(response: 0.15, dampingFraction: 0.7)
    
    /// Smooth transition for UI state changes
    /// Use for: Card expansions, list animations, revealing content
    static let grootSmooth = Animation.spring(response: 0.35, dampingFraction: 0.8)
    
    /// Calm animation for navigation
    /// Use for: Sheets, modals, navigation pushes
    static let grootCalm = Animation.spring(response: 0.6, dampingFraction: 1.0)
    
    /// Energetic overshoot for attention-grabbing moments
    /// Use for: New blocks, milestones, special notifications
    static let grootEnergetic = Animation.spring(response: 0.4, dampingFraction: 0.4)
    
    /// Shield animation - protective feeling
    /// Use for: Block confirmation, protection enabled
    static let grootShield = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - Haptic Feedback

struct GrootHaptics {
    
    /// Button press feedback
    static func buttonPress() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
    }
    
    /// Success feedback - call blocked, number added
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// Error feedback - validation error, failed action
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    /// Warning feedback - confirm delete, important action
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    /// Selection change feedback
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    /// Block confirmed - satisfying feedback burst
    static func blockConfirmed() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 0.6)
        }
    }
    
    /// Milestone reached
    static func milestone() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred(intensity: 0.5)
        }
    }
}

// MARK: - Animation View Modifiers

extension View {
    
    /// Apply bouncy animation
    func grootBouncy<V: Equatable>(value: V) -> some View {
        self.animation(.grootBouncy, value: value)
    }
    
    /// Apply snappy animation
    func grootSnappy<V: Equatable>(value: V) -> some View {
        self.animation(.grootSnappy, value: value)
    }
    
    /// Apply smooth animation
    func grootSmooth<V: Equatable>(value: V) -> some View {
        self.animation(.grootSmooth, value: value)
    }
    
    /// Apply calm animation
    func grootCalm<V: Equatable>(value: V) -> some View {
        self.animation(.grootCalm, value: value)
    }
    
    /// Shake animation for errors
    func grootShake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
    
    /// Pulse animation for attention
    func grootPulse(isActive: Bool) -> some View {
        self.modifier(PulseModifier(isActive: isActive))
    }
    
    /// Scale bounce for success
    func grootSuccessBounce(trigger: Bool) -> some View {
        self.modifier(SuccessBounceModifier(trigger: trigger))
    }
}

// MARK: - Shake Modifier

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shakeOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) {
                    shakeOffset = -10
                }
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3).delay(0.08)) {
                    shakeOffset = 10
                }
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3).delay(0.16)) {
                    shakeOffset = -5
                }
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5).delay(0.24)) {
                    shakeOffset = 0
                }
            }
    }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        scale = 1.05
                    }
                } else {
                    withAnimation(.grootSnappy) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Success Bounce Modifier

struct SuccessBounceModifier: ViewModifier {
    let trigger: Bool
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                    scale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                    scale = 1.0
                }
            }
    }
}

// MARK: - Appear Animation Modifier

struct AppearAnimationModifier: ViewModifier {
    let delay: Double
    let animateOnce: Bool
    
    @State private var isVisible = false
    @State private var hasAnimated = false
    
    init(delay: Double, animateOnce: Bool = true) {
        self.delay = delay
        self.animateOnce = animateOnce
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                // If animateOnce is true and we've already animated, just show immediately
                if animateOnce && hasAnimated {
                    isVisible = true
                    return
                }
                
                // Animate in
                withAnimation(.grootSmooth.delay(delay)) {
                    isVisible = true
                }
                hasAnimated = true
            }
    }
}

extension View {
    /// Animate view appearance with staggered delay
    /// - Parameters:
    ///   - delay: Delay before animation starts
    ///   - animateOnce: If true (default), only animates the first time. Set to false to animate every appear.
    func grootAppear(delay: Double = 0, animateOnce: Bool = true) -> some View {
        self.modifier(AppearAnimationModifier(delay: delay, animateOnce: animateOnce))
    }
}

// MARK: - Press Effect Modifier

struct PressEffectModifier: ViewModifier {
    let isPressed: Bool
    let shadowOffset: CGFloat
    
    init(isPressed: Bool, shadowOffset: CGFloat = 4) {
        self.isPressed = isPressed
        self.shadowOffset = shadowOffset
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: isPressed ? shadowOffset : 0)
            .animation(.grootSnappy, value: isPressed)
    }
}
