import SwiftUI

// MARK: - Mascot Mood

enum MascotMood: Int, CaseIterable {
    case idle = 0       // Default breathing, occasional blink
    case happy = 1      // Bouncy, sparkles, ^_^ eyes
    case blocking = 2   // Arm raised, serious, red glow
    case sleeping = 3   // Eyes closed, zzz, slow breathing
    
    var floatValue: Float {
        Float(rawValue)
    }
    
    var displayName: String {
        switch self {
        case .idle: return "idle"
        case .happy: return "happy"
        case .blocking: return "blocking"
        case .sleeping: return "sleeping"
        }
    }
}

// MARK: - Groot Mascot View (Metal Shader Version)

struct GrootMascot: View {
    var size: CGFloat = 200
    var mood: MascotMood = .idle
    var useShader: Bool = true
    
    @State private var startDate = Date()
    
    var body: some View {
        if useShader {
            shaderMascot
        } else {
            GrootMascotFallback(size: size, mood: mood)
        }
    }
    
    @ViewBuilder
    private var shaderMascot: some View {
        TimelineView(.animation) { context in
            let time = Float(context.date.timeIntervalSince(startDate))
            let breathe = calculateBreathe(time: time)
            let blink = calculateBlink(time: time, currentTime: context.date.timeIntervalSince(startDate))
            
            Rectangle()
                .fill(.white)
                .frame(width: size, height: size)
                .colorEffect(
                    ShaderLibrary.grootMascot(
                        .float2(size, size),
                        .float(time),
                        .float(mood.floatValue),
                        .float(blink),
                        .float(breathe)
                    )
                )
        }
        .frame(width: size, height: size)
        .drawingGroup()
    }
    
    // MARK: - Animation Calculations
    
    private func calculateBreathe(time: Float) -> Float {
        switch mood {
        case .idle:
            return sin(time * 2.0) * 0.5 + 0.5
        case .happy:
            return sin(time * 4.0) * 0.5 + 0.5
        case .blocking:
            return sin(time * 1.5) * 0.3 + 0.5
        case .sleeping:
            return sin(time * 1.0) * 0.5 + 0.5
        }
    }
    
    private func calculateBlink(time: Float, currentTime: TimeInterval) -> Float {
        // In sleeping mode, eyes are always "closed"
        if mood == .sleeping {
            return 1.0
        }
        
        // In happy mode, no blinking (^_^ eyes)
        if mood == .happy {
            return 0.0
        }
        
        // Random blinking every 3-5 seconds
        let blinkInterval: TimeInterval = 3.5
        let blinkDuration: Float = 0.15
        
        let timeSinceLastBlink = Float(fmod(currentTime, blinkInterval))
        
        // Quick blink: 0 -> 1 -> 0 over blinkDuration
        if timeSinceLastBlink < blinkDuration {
            let t = timeSinceLastBlink / blinkDuration
            // Smooth blink curve (ease in-out)
            return sin(t * .pi)
        }
        
        return 0.0
    }
}

// MARK: - Animated Mood Transition

struct AnimatedGrootMascot: View {
    var size: CGFloat = 200
    @Binding var mood: MascotMood
    
    @State private var startDate = Date()
    @State private var currentMoodFloat: Float = 0
    
    var body: some View {
        TimelineView(.animation) { context in
            let time = Float(context.date.timeIntervalSince(startDate))
            let breathe = calculateBreathe(time: time)
            let blink = calculateBlink(time: time)
            
            Rectangle()
                .fill(.white)
                .frame(width: size, height: size)
                .colorEffect(
                    ShaderLibrary.grootMascot(
                        .float2(size, size),
                        .float(time),
                        .float(currentMoodFloat),
                        .float(blink),
                        .float(breathe)
                    )
                )
        }
        .frame(width: size, height: size)
        .drawingGroup()
        .onChange(of: mood) { _, newMood in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentMoodFloat = newMood.floatValue
            }
        }
        .onAppear {
            currentMoodFloat = mood.floatValue
        }
    }
    
    private func calculateBreathe(time: Float) -> Float {
        let moodFactor = smoothstep(0, 1, currentMoodFloat / 3.0)
        let baseSpeed = 2.0 - moodFactor * 1.0
        return sin(time * baseSpeed) * 0.5 + 0.5
    }
    
    private func calculateBlink(time: Float) -> Float {
        // Sleeping
        if currentMoodFloat > 2.5 {
            return 1.0
        }
        // Happy
        if currentMoodFloat > 0.5 && currentMoodFloat < 1.5 {
            return 0.0
        }
        
        // Regular blinking
        let blinkInterval: Float = 3.5
        let blinkDuration: Float = 0.15
        let timeSinceLastBlink = fmod(time, blinkInterval)
        
        if timeSinceLastBlink < blinkDuration {
            return sin(timeSinceLastBlink / blinkDuration * .pi)
        }
        return 0.0
    }
    
    private func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
        let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
        return t * t * (3 - 2 * t)
    }
}

// MARK: - Interactive Mascot (responds to touch)

struct InteractiveGrootMascot: View {
    var size: CGFloat = 200
    var useShader: Bool = false // Default to fallback for compatibility
    @State private var mood: MascotMood = .idle
    @State private var isPressed = false
    
    var body: some View {
        Group {
            if useShader {
                AnimatedGrootMascot(size: size, mood: $mood)
            } else {
                GrootMascotFallback(size: size, mood: mood)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        mood = .happy
                        GrootHaptics.buttonPress()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    // Return to idle after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if mood == .happy {
                            mood = .idle
                        }
                    }
                }
        )
        .onTapGesture(count: 2) {
            // Double tap cycles through moods
            let nextMoodRaw = (mood.rawValue + 1) % MascotMood.allCases.count
            mood = MascotMood(rawValue: nextMoodRaw) ?? .idle
            GrootHaptics.success()
        }
    }
}

// MARK: - Mascot with Caption

struct GrootMascotWithCaption: View {
    var size: CGFloat = 200
    var mood: MascotMood = .idle
    var caption: String? = nil
    var useShader: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            if useShader {
                GrootMascot(size: size, mood: mood, useShader: true)
            } else {
                GrootMascotFallback(size: size, mood: mood)
            }
            
            if let caption {
                Text(caption.lowercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // Convenience initializers for common states
    static func blocking(size: CGFloat = 200, caption: String = "call blocked!") -> GrootMascotWithCaption {
        GrootMascotWithCaption(size: size, mood: .blocking, caption: caption)
    }
    
    static func success(size: CGFloat = 200, caption: String = "you're protected!") -> GrootMascotWithCaption {
        GrootMascotWithCaption(size: size, mood: .happy, caption: caption)
    }
    
    static func sleeping(size: CGFloat = 200, caption: String = "all quiet...") -> GrootMascotWithCaption {
        GrootMascotWithCaption(size: size, mood: .sleeping, caption: caption)
    }
}

// MARK: - View Modifier for Mascot Overlay

extension View {
    func grootMascotOverlay(
        isShowing: Binding<Bool>,
        mood: MascotMood = .happy,
        size: CGFloat = 150,
        position: UnitPoint = .center
    ) -> some View {
        self.overlay {
            if isShowing.wrappedValue {
                GrootMascot(size: size, mood: mood)
                    .position(
                        x: position.x * UIScreen.main.bounds.width,
                        y: position.y * UIScreen.main.bounds.height
                    )
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.grootSmooth) {
                                isShowing.wrappedValue = false
                            }
                        }
                    }
            }
        }
        .animation(.grootBouncy, value: isShowing.wrappedValue)
    }
}

// MARK: - Robot Mascot (SwiftUI)

struct GrootMascotFallback: View {
    var size: CGFloat = 200
    var mood: MascotMood = .idle
    
    @State private var breatheScale: CGFloat = 1.0
    @State private var eyesClosed = false
    @State private var bounceOffset: CGFloat = 0
    @State private var antennaWobble: Double = 0
    
    private var scale: CGFloat { size / 200 }
    
    var body: some View {
        ZStack {
            // Robot body
            VStack(spacing: 0) {
                // Antenna
                RobotAntenna(scale: scale, mood: mood, wobble: antennaWobble)
                    .offset(y: 8 * scale)
                
                // Head
                RobotHead(scale: scale, mood: mood, eyesClosed: eyesClosed)
                
                // Body
                RobotBody(scale: scale, mood: mood)
            }
            
            // Sparkles (happy mode)
            if mood == .happy {
                RobotSparkles(scale: scale)
            }
            
            // ZZZ (sleeping mode)
            if mood == .sleeping {
                RobotZzz(scale: scale)
            }
            
            // Shield icon (blocking mode)
            if mood == .blocking {
                RobotShieldIcon(scale: scale)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(breatheScale)
        .offset(y: bounceOffset)
        .onAppear {
            startAnimations()
        }
        .onChange(of: mood) { _, _ in
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Breathing animation
        let breatheDuration: Double = mood == .sleeping ? 3.0 : 2.0
        let breatheAmount: CGFloat = mood == .happy ? 1.03 : 1.015
        
        withAnimation(.easeInOut(duration: breatheDuration).repeatForever(autoreverses: true)) {
            breatheScale = breatheAmount
        }
        
        // Antenna wobble
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            antennaWobble = mood == .happy ? 15 : 5
        }
        
        // Bounce for happy
        if mood == .happy {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                bounceOffset = -8
            }
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                bounceOffset = 0
            }
        }
        
        // Blinking
        if mood == .idle || mood == .blocking {
            startBlinking()
        }
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            guard mood == .idle || mood == .blocking else { return }
            withAnimation(.easeInOut(duration: 0.1)) {
                eyesClosed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    eyesClosed = false
                }
            }
        }
    }
}

// MARK: - Robot Antenna

struct RobotAntenna: View {
    var scale: CGFloat
    var mood: MascotMood
    var wobble: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Antenna ball
            Circle()
                .fill(antennaColor)
                .frame(width: 14 * scale, height: 14 * scale)
                .shadow(color: antennaColor.opacity(0.6), radius: 6)
            
            // Antenna stick
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(Color.grootStone)
                .frame(width: 4 * scale, height: 16 * scale)
        }
        .rotationEffect(.degrees(wobble))
    }
    
    private var antennaColor: Color {
        switch mood {
        case .idle: return .grootSky
        case .happy: return .grootLeaf
        case .blocking: return .grootFlame
        case .sleeping: return .grootViolet.opacity(0.5)
        }
    }
}

// MARK: - Robot Head

struct RobotHead: View {
    var scale: CGFloat
    var mood: MascotMood
    var eyesClosed: Bool
    
    var body: some View {
        ZStack {
            // Head base - rounded rectangle
            RoundedRectangle(cornerRadius: 24 * scale)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#F8F9FA"), Color(hex: "#E9ECEF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 110 * scale, height: 90 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 24 * scale)
                        .strokeBorder(Color.grootMist, lineWidth: 2 * scale)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
            
            // Face screen
            RoundedRectangle(cornerRadius: 16 * scale)
                .fill(Color(hex: "#1A1A2E"))
                .frame(width: 90 * scale, height: 60 * scale)
                .overlay(
                    // Screen content
                    VStack(spacing: 6 * scale) {
                        // Eyes
                        HStack(spacing: 24 * scale) {
                            RobotEye(scale: scale, mood: mood, isLeft: true, closed: eyesClosed)
                            RobotEye(scale: scale, mood: mood, isLeft: false, closed: eyesClosed)
                        }
                        
                        // Mouth
                        RobotMouth(scale: scale, mood: mood)
                    }
                )
            
            // Ear pieces
            HStack(spacing: 100 * scale) {
                RoundedRectangle(cornerRadius: 4 * scale)
                    .fill(Color.grootStone)
                    .frame(width: 8 * scale, height: 20 * scale)
                
                RoundedRectangle(cornerRadius: 4 * scale)
                    .fill(Color.grootStone)
                    .frame(width: 8 * scale, height: 20 * scale)
            }
        }
    }
}

// MARK: - Robot Eye

struct RobotEye: View {
    var scale: CGFloat
    var mood: MascotMood
    var isLeft: Bool
    var closed: Bool
    
    var body: some View {
        Group {
            if mood == .sleeping || closed {
                // Closed - horizontal line
                Capsule()
                    .fill(eyeColor)
                    .frame(width: 18 * scale, height: 3 * scale)
            } else if mood == .happy {
                // Happy - curved up ^
                HappyRobotEye(scale: scale, color: eyeColor)
            } else if mood == .blocking {
                // Determined - angled
                Rectangle()
                    .fill(eyeColor)
                    .frame(width: 18 * scale, height: 4 * scale)
                    .rotationEffect(.degrees(isLeft ? -10 : 10))
            } else {
                // Normal - rounded rectangle
                RoundedRectangle(cornerRadius: 4 * scale)
                    .fill(eyeColor)
                    .frame(width: 18 * scale, height: 14 * scale)
            }
        }
    }
    
    private var eyeColor: Color {
        switch mood {
        case .idle: return .grootSky
        case .happy: return .grootLeaf
        case .blocking: return .grootFlame
        case .sleeping: return .grootViolet.opacity(0.6)
        }
    }
}

struct HappyRobotEye: View {
    var scale: CGFloat
    var color: Color
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 12 * scale))
            path.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 12 * scale),
                control: CGPoint(x: 9 * scale, y: 0)
            )
        }
        .stroke(color, style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round))
        .frame(width: 18 * scale, height: 14 * scale)
    }
}

// MARK: - Robot Mouth

struct RobotMouth: View {
    var scale: CGFloat
    var mood: MascotMood
    
    var body: some View {
        Group {
            switch mood {
            case .idle:
                // Small smile
                RoundedRectangle(cornerRadius: 2 * scale)
                    .fill(Color.grootSky)
                    .frame(width: 20 * scale, height: 4 * scale)
            case .happy:
                // Big smile curve
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 30 * scale, y: 0),
                        control: CGPoint(x: 15 * scale, y: 12 * scale)
                    )
                }
                .stroke(Color.grootLeaf, style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round))
                .frame(width: 30 * scale, height: 12 * scale)
            case .blocking:
                // Straight serious line
                RoundedRectangle(cornerRadius: 2 * scale)
                    .fill(Color.grootFlame)
                    .frame(width: 24 * scale, height: 4 * scale)
            case .sleeping:
                // Small "o"
                Circle()
                    .stroke(Color.grootViolet.opacity(0.6), lineWidth: 2 * scale)
                    .frame(width: 10 * scale, height: 10 * scale)
            }
        }
    }
}

// MARK: - Robot Body

struct RobotBody: View {
    var scale: CGFloat
    var mood: MascotMood
    
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 20 * scale)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#F8F9FA"), Color(hex: "#DEE2E6")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 80 * scale, height: 50 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 20 * scale)
                        .strokeBorder(Color.grootMist, lineWidth: 2 * scale)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
            
            // Chest light/badge
            Circle()
                .fill(chestColor)
                .frame(width: 16 * scale, height: 16 * scale)
                .shadow(color: chestColor.opacity(0.6), radius: 4)
            
            // Arms
            HStack(spacing: 70 * scale) {
                // Left arm
                RobotArm(scale: scale, isLeft: true, mood: mood)
                
                // Right arm
                RobotArm(scale: scale, isLeft: false, mood: mood)
            }
        }
        .offset(y: -5 * scale)
    }
    
    private var chestColor: Color {
        switch mood {
        case .idle: return .grootSky
        case .happy: return .grootLeaf
        case .blocking: return .grootFlame
        case .sleeping: return .grootViolet.opacity(0.5)
        }
    }
}

// MARK: - Robot Arm

struct RobotArm: View {
    var scale: CGFloat
    var isLeft: Bool
    var mood: MascotMood
    
    @State private var waveRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 2 * scale) {
            // Upper arm
            RoundedRectangle(cornerRadius: 4 * scale)
                .fill(Color.grootStone)
                .frame(width: 10 * scale, height: 20 * scale)
            
            // Hand
            Circle()
                .fill(Color(hex: "#F8F9FA"))
                .frame(width: 14 * scale, height: 14 * scale)
                .overlay(
                    Circle()
                        .strokeBorder(Color.grootMist, lineWidth: 1.5 * scale)
                )
        }
        .rotationEffect(.degrees(armRotation + (mood == .happy ? waveRotation : 0)), anchor: .top)
        .onAppear {
            if mood == .happy && !isLeft {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    waveRotation = 30
                }
            }
        }
        .onChange(of: mood) { _, newMood in
            if newMood == .happy && !isLeft {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    waveRotation = 30
                }
            } else {
                waveRotation = 0
            }
        }
    }
    
    private var armRotation: Double {
        if mood == .blocking && !isLeft {
            return -60 // Right arm raised
        }
        return isLeft ? 20 : -20
    }
}

// MARK: - Robot Sparkles

struct RobotSparkles: View {
    var scale: CGFloat
    
    @State private var sparkleScale: CGFloat = 0.8
    @State private var sparkleOpacity: Double = 1
    
    var body: some View {
        ForEach(0..<5, id: \.self) { i in
            Image(systemName: "sparkle")
                .font(.system(size: 12 * scale, weight: .bold))
                .foregroundStyle(Color.grootLeaf)
                .scaleEffect(sparkleScale)
                .opacity(sparkleOpacity)
                .offset(
                    x: sparklePosition(index: i).x * scale,
                    y: sparklePosition(index: i).y * scale
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                sparkleScale = 1.2
                sparkleOpacity = 0.5
            }
        }
    }
    
    private func sparklePosition(index: Int) -> CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: -70, y: -40),
            CGPoint(x: 70, y: -30),
            CGPoint(x: -60, y: 30),
            CGPoint(x: 65, y: 40),
            CGPoint(x: 0, y: -70)
        ]
        return positions[index % positions.count]
    }
}

// MARK: - Robot Zzz

struct RobotZzz: View {
    var scale: CGFloat
    
    @State private var floatOffset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4 * scale) {
            ForEach(0..<3, id: \.self) { i in
                Text("z")
                    .font(.system(size: (10 + CGFloat(i) * 3) * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootViolet)
                    .offset(y: floatOffset - CGFloat(i) * 5)
                    .opacity(opacity - Double(i) * 0.2)
            }
        }
        .offset(x: 50 * scale, y: -50 * scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatOffset = -15
                opacity = 0.4
            }
        }
    }
}

// MARK: - Robot Shield Icon (Blocking Mode)

struct RobotShieldIcon: View {
    var scale: CGFloat
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "shield.fill")
            .font(.system(size: 24 * scale, weight: .bold))
            .foregroundStyle(Color.grootFlame)
            .scaleEffect(pulseScale)
            .offset(x: 50 * scale, y: -40 * scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                }
            }
    }
}

// MARK: - Preview

#Preview("Groot Mascot (SwiftUI Fallback)") {
    ScrollView {
        VStack(spacing: 40) {
            Text("groot mascot")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.grootBark)
            
            // All moods using fallback
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                ForEach(MascotMood.allCases, id: \.self) { mood in
                    VStack(spacing: 12) {
                        GrootMascotFallback(size: 150, mood: mood)
                        
                        Text(mood.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                }
            }
            
            Divider()
                .padding(.vertical)
            
            // Interactive version
            Text("tap me!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootStone)
            
            InteractiveGrootMascot(size: 200)
            
            Text("double tap to change mood")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootPebble)
        }
        .padding(30)
    }
    .background(Color.grootCloud)
}

#Preview("Groot Mascot (Metal Shader)") {
    ScrollView {
        VStack(spacing: 40) {
            Text("metal shader version")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.grootBark)
            
            Text("if blank, add GrootMascot.metal to xcode project")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootStone)
            
            // All moods using Metal shader
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                ForEach(MascotMood.allCases, id: \.self) { mood in
                    VStack(spacing: 12) {
                        GrootMascot(size: 150, mood: mood, useShader: true)
                        
                        Text(mood.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                }
            }
        }
        .padding(30)
    }
    .background(Color.grootCloud)
}

#Preview("Mascot with Caption") {
    VStack(spacing: 40) {
        GrootMascotWithCaption.blocking()
        GrootMascotWithCaption.success()
        GrootMascotWithCaption.sleeping()
    }
    .padding()
    .background(Color.grootCloud)
}
