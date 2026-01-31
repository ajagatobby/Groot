import SwiftUI
import CallKit

// MARK: - Welcome View

struct WelcomeView: View {
    @State private var currentPage = 0
    @State private var extensionEnabled = false
    
    var onComplete: () -> Void
    
    private let totalPages = 5
    
    init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            Color.grootSnow
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar at top
                WelcomeProgressBar(currentPage: currentPage, totalPages: totalPages)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Page content
                TabView(selection: $currentPage) {
                    WelcomeHeroPage()
                        .tag(0)
                    
                    BlockSpamPage()
                        .tag(1)
                    
                    SmartFeaturesPage()
                        .tag(2)
                    
                    EnableProtectionPage(
                        isEnabled: $extensionEnabled,
                        onCheckStatus: checkExtensionStatus
                    )
                    .tag(3)
                    
                    GetStartedPage(extensionEnabled: extensionEnabled)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Bottom navigation
                WelcomeBottomNav(
                    currentPage: $currentPage,
                    totalPages: totalPages,
                    onComplete: onComplete
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            checkExtensionStatus()
        }
    }
    
    private func checkExtensionStatus() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
            withIdentifier: "com.reelsynth.Groot.CallDirectory"
        ) { status, error in
            DispatchQueue.main.async {
                extensionEnabled = (status == .enabled)
            }
        }
    }
}

// MARK: - Progress Bar

struct WelcomeProgressBar: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? Color.grootShield : Color.grootMist)
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
            }
        }
    }
}

// MARK: - Page 1: Hero

struct WelcomeHeroPage: View {
    @State private var showMascot = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Mascot
            GrootMascotFallback(size: 200, mood: .happy)
                .scaleEffect(showMascot ? 1 : 0.3)
                .opacity(showMascot ? 1 : 0)
                .rotationEffect(.degrees(showMascot ? 0 : -10))
            
            Spacer()
                .frame(height: 48)
            
            // Title section
            VStack(spacing: 12) {
                Text("meet groot")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 30)
                
                Text("your personal call guardian that\nblocks spam before it rings")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 25)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        // Reset
        showMascot = false
        showTitle = false
        showSubtitle = false
        
        // Staggered animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                showMascot = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
    }
}

// MARK: - Page 2: Block Spam

struct BlockSpamPage: View {
    @State private var showCircle = false
    @State private var showIcon = false
    @State private var showBadge = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showTags: [Bool] = [false, false, false]
    @State private var blockedCount = 0
    @State private var counterTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Illustration
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.grootFlame.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(showCircle ? 1 : 0.5)
                    .opacity(showCircle ? 1 : 0)
                
                // Icon
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(Color.grootFlame)
                    .scaleEffect(showIcon ? 1 : 0.3)
                    .opacity(showIcon ? 1 : 0)
                
                // Counter badge
                Text("\(blockedCount)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.grootFlame)
                    .clipShape(Capsule())
                    .offset(x: 70, y: -70)
                    .scaleEffect(showBadge ? 1 : 0)
                    .opacity(showBadge ? 1 : 0)
            }
            
            Spacer()
                .frame(height: 48)
            
            // Text content
            VStack(spacing: 12) {
                Text("block spam calls")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 30)
                
                Text("automatically filter robocalls,\ntelemarketers, and scam attempts")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 25)
            }
            
            // Tags
            HStack(spacing: 10) {
                BlockSpamTag(text: "robocalls", color: .grootFlame, isVisible: showTags[0])
                BlockSpamTag(text: "telemarketers", color: .grootAmber, isVisible: showTags[1])
                BlockSpamTag(text: "scams", color: .grootSun, isVisible: showTags[2])
            }
            .padding(.top, 24)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
        .onDisappear {
            counterTimer?.invalidate()
            counterTimer = nil
        }
    }
    
    private func animateIn() {
        // Cancel any existing timer
        counterTimer?.invalidate()
        counterTimer = nil
        
        // Reset all states
        showCircle = false
        showIcon = false
        showBadge = false
        showTitle = false
        showSubtitle = false
        showTags = [false, false, false]
        blockedCount = 0
        
        // Staggered animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCircle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                showIcon = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showBadge = true
            }
            // Start counter animation
            counterTimer = Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
                if blockedCount < 127 {
                    blockedCount += 2
                } else {
                    blockedCount = 127
                    timer.invalidate()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
        
        // Tags
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showTags[i] = true
                }
            }
        }
    }
}

struct BlockSpamTag: View {
    var text: String
    var color: Color
    var isVisible: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
    }
}

// MARK: - Page 3: Smart Features

struct SmartFeaturesPage: View {
    @State private var showCircle = false
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showFeatures: [Bool] = [false, false, false]
    
    let features: [(icon: String, title: String, subtitle: String)] = [
        ("globe.americas.fill", "country blocking", "block entire regions"),
        ("number.circle.fill", "pattern rules", "create custom rules"),
        ("person.badge.shield.checkmark.fill", "whitelist", "protect important contacts")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.grootShield.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(showCircle ? 1 : 0.5)
                    .opacity(showCircle ? 1 : 0)
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(Color.grootShield)
                    .scaleEffect(showIcon ? 1 : 0.3)
                    .opacity(showIcon ? 1 : 0)
            }
            
            Spacer()
                .frame(height: 48)
            
            // Text content
            VStack(spacing: 12) {
                Text("smart protection")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 30)
                
                Text("powerful tools to control\nwho can reach you")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 25)
            }
            
            // Feature list
            VStack(spacing: 12) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    SmartFeatureRow(
                        icon: feature.icon,
                        title: feature.title,
                        subtitle: feature.subtitle,
                        isVisible: showFeatures[index]
                    )
                }
            }
            .padding(.top, 32)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        // Reset all states
        showCircle = false
        showIcon = false
        showTitle = false
        showSubtitle = false
        showFeatures = [false, false, false]
        
        // Staggered animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCircle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                showIcon = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
        
        // Feature rows
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    showFeatures[i] = true
                }
            }
        }
    }
}

struct SmartFeatureRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.grootShield.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.grootShield)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.grootCloud)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -40)
    }
}

// MARK: - Page 4: Enable Protection

struct EnableProtectionPage: View {
    @Binding var isEnabled: Bool
    var onCheckStatus: () -> Void
    
    @State private var showCircle = false
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showSteps = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill((isEnabled ? Color.grootShield : Color.grootSky).opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(showCircle ? 1 : 0.5)
                    .opacity(showCircle ? 1 : 0)
                
                Image(systemName: isEnabled ? "checkmark.shield.fill" : "gearshape.2.fill")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.grootShield : Color.grootSky)
                    .scaleEffect(showIcon ? 1 : 0.3)
                    .opacity(showIcon ? 1 : 0)
            }
            
            Spacer()
                .frame(height: 48)
            
            // Text content
            VStack(spacing: 12) {
                Text(isEnabled ? "protection enabled!" : "enable protection")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 30)
                
                Text(isEnabled 
                     ? "groot is now blocking\nunwanted calls for you"
                     : "one quick step to activate\ncall blocking on your phone")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 25)
            }
            
            // Instructions (only show if not enabled)
            if !isEnabled {
                VStack(alignment: .leading, spacing: 16) {
                    EnableStepRow(number: 1, text: "Tap 'Open Settings' below")
                    EnableStepRow(number: 2, text: "Go to Call Blocking & Identification")
                    EnableStepRow(number: 3, text: "Toggle ON for Groot")
                }
                .padding(.top, 32)
                .opacity(showSteps ? 1 : 0)
                .offset(y: showSteps ? 0 : 20)
                
                // Open Settings button
                Button {
                    openCallBlockingSettings()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .semibold))
                        Text("open settings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.grootSky)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.grootSky.opacity(0.15))
                    .clipShape(Capsule())
                }
                .padding(.top, 24)
                .opacity(showButton ? 1 : 0)
                .scaleEffect(showButton ? 1 : 0.9)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
        .onChange(of: isEnabled) { _, _ in
            // Re-animate when status changes
            if isEnabled {
                GrootHaptics.success()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Check status when returning from Settings
            onCheckStatus()
        }
    }
    
    private func openCallBlockingSettings() {
        // Use the official CallKit API to open Call Blocking settings
        // This is the Apple-recommended way and won't cause App Store rejection
        
        Task {
            do {
                // iOS 17+ async version
                try await CXCallDirectoryManager.sharedInstance.openSettings()
            } catch {
                // Fallback: Open Phone settings via URL scheme
                print("CXCallDirectoryManager.openSettings failed: \(error)")
                await MainActor.run {
                    let urlStrings = [
                        "App-prefs:root=Phone",
                        "prefs:root=Phone",
                        UIApplication.openSettingsURLString
                    ]
                    
                    for urlString in urlStrings {
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func animateIn() {
        showCircle = false
        showIcon = false
        showTitle = false
        showSubtitle = false
        showSteps = false
        showButton = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCircle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                showIcon = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSteps = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showButton = true
            }
        }
    }
}

struct EnableStepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.grootSky.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootSky)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootBark)
        }
    }
}

// MARK: - Page 5: Get Started

struct GetStartedPage: View {
    var extensionEnabled: Bool = false
    
    @State private var showMascot = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var mascotMood: MascotMood = .idle
    @State private var checkmarksVisible: [Bool] = [false, false, false]
    
    var benefits: [String] {
        if extensionEnabled {
            return [
                "call blocking is active",
                "100% private, on-device only",
                "no ads, no tracking, ever"
            ]
        } else {
            return [
                "100% free, no ads ever",
                "works entirely on your device",
                "no data collection or tracking"
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Mascot
            GrootMascotFallback(size: 180, mood: mascotMood)
                .scaleEffect(showMascot ? 1 : 0.3)
                .opacity(showMascot ? 1 : 0)
                .rotationEffect(.degrees(showMascot ? 0 : 10))
            
            Spacer()
                .frame(height: 48)
            
            // Title
            VStack(spacing: 12) {
                Text(extensionEnabled ? "you're protected!" : "you're all set!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 30)
                
                Text(extensionEnabled 
                     ? "groot is actively blocking\nunwanted calls for you"
                     : "groot is ready to protect\nyou from unwanted calls")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 25)
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                    GetStartedBenefitRow(
                        text: benefit,
                        isVisible: checkmarksVisible[index]
                    )
                }
            }
            .padding(.top, 32)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        // Reset all state
        showMascot = false
        showTitle = false
        showSubtitle = false
        mascotMood = .idle
        checkmarksVisible = [false, false, false]
        
        // Staggered animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                showMascot = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
            mascotMood = .happy
        }
        
        // Checkmarks with haptics
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    checkmarksVisible[i] = true
                }
                GrootHaptics.buttonPress()
            }
        }
    }
}

struct GetStartedBenefitRow: View {
    var text: String
    var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.grootMist, lineWidth: 2)
                    .frame(width: 26, height: 26)
                
                Circle()
                    .fill(Color.grootShield)
                    .frame(width: 26, height: 26)
                    .scaleEffect(isVisible ? 1 : 0)
                    .opacity(isVisible ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(isVisible ? 1 : 0)
                    .opacity(isVisible ? 1 : 0)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootBark)
                .opacity(isVisible ? 1 : 0.5)
        }
    }
}

// MARK: - Bottom Navigation

struct WelcomeBottomNav: View {
    @Binding var currentPage: Int
    var totalPages: Int
    var onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Skip/Back button (not on last page)
            if currentPage < totalPages - 1 {
                Button {
                    if currentPage == 0 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentPage = totalPages - 1
                        }
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentPage -= 1
                        }
                    }
                    GrootHaptics.buttonPress()
                } label: {
                    Text(currentPage == 0 ? "skip" : "back")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.grootCloud)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            // Continue/Get Started button - Duolingo style
            Button {
                if currentPage < totalPages - 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
                GrootHaptics.buttonPress()
            } label: {
                Text(currentPage < totalPages - 1 ? "continue" : "get started")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.grootShield)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    // Duolingo 3D shadow effect
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.grootForest)
                            .offset(y: 4)
                    )
            }
            .buttonStyle(DuolingoButtonStyle())
        }
    }
}

// MARK: - Duolingo Button Style

struct DuolingoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Welcome Flow") {
    WelcomeView()
}

#Preview("Hero Page") {
    WelcomeHeroPage()
        .background(Color.grootSnow)
}

#Preview("Block Spam Page") {
    BlockSpamPage()
        .background(Color.grootSnow)
}

#Preview("Smart Features Page") {
    SmartFeaturesPage()
        .background(Color.grootSnow)
}

#Preview("Enable Protection Page") {
    EnableProtectionPage(isEnabled: .constant(false), onCheckStatus: {})
        .background(Color.grootSnow)
}

#Preview("Get Started Page") {
    GetStartedPage(extensionEnabled: true)
        .background(Color.grootSnow)
}
