//
//  PermissionsView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import CallKit
import UserNotifications
import Contacts
import UIKit

// MARK: - Permissions View

struct PermissionsView: View {
    var onComplete: () -> Void
    
    @State private var permissions: [PermissionItem] = []
    @State private var currentIndex = 0
    @State private var showContent = false
    @State private var isProcessing = false
    @State private var allPermissionsHandled = false
    @State private var waitingForSettingsReturn = false
    
    var body: some View {
        ZStack {
            Color.grootSnow
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                PermissionsHeader(
                    currentIndex: currentIndex,
                    totalCount: permissions.count
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                if allPermissionsHandled {
                    // All done view
                    PermissionsCompleteView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else if !permissions.isEmpty {
                    // Current permission card
                    PermissionCardView(permission: permissions[currentIndex])
                        .id(currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                Spacer()
                
                // Bottom buttons
                if allPermissionsHandled {
                    Button {
                        GrootHaptics.success()
                        onComplete()
                    } label: {
                        Text("start using groot")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(Color.grootShield)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.grootForest)
                                    .offset(y: 4)
                            )
                    }
                    .buttonStyle(DuolingoButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !permissions.isEmpty {
                    // Permission action buttons
                    VStack(spacing: 16) {
                        // Main action button
                        Button {
                            handlePermission(allow: true)
                        } label: {
                            HStack(spacing: 8) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: permissions[currentIndex].type == .callBlocking ? "gear" : "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                
                                Text(permissions[currentIndex].type == .callBlocking ? "open settings" : "allow")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(permissions[currentIndex].iconColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(permissions[currentIndex].iconColor.opacity(0.7))
                                    .offset(y: 4)
                            )
                        }
                        .buttonStyle(DuolingoButtonStyle())
                        .disabled(isProcessing)
                        
                        // For call blocking, show "I've enabled it" after opening settings
                        if permissions[currentIndex].type == .callBlocking && waitingForSettingsReturn {
                            Button {
                                checkCallBlockingAndProceed()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("i've enabled it")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(Color.grootShield)
                            }
                        }
                        
                        // Skip button
                        Button {
                            handlePermission(allow: false)
                        } label: {
                            Text("skip for now")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.grootStone)
                        }
                        .disabled(isProcessing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            setupPermissions()
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
        // Auto-check when returning from Settings
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if waitingForSettingsReturn && !permissions.isEmpty && permissions[currentIndex].type == .callBlocking {
                checkCallBlockingAndProceed()
            }
        }
    }
    
    private func checkCallBlockingAndProceed() {
        Task {
            let status = await checkPermissionStatus(.callBlocking)
            await MainActor.run {
                if status == .granted {
                    GrootHaptics.success()
                    permissions[currentIndex].status = .granted
                    moveToNext()
                }
            }
        }
    }
    
    private func setupPermissions() {
        permissions = [
            PermissionItem(
                type: .notifications,
                icon: "bell.badge.fill",
                iconColor: .grootSun,
                title: "stay informed",
                subtitle: "Get notified when Groot blocks spam calls so you know you're protected.",
                benefit: "know when spam is blocked"
            ),
            PermissionItem(
                type: .callBlocking,
                icon: "phone.down.fill",
                iconColor: .grootFlame,
                title: "block spam calls",
                subtitle: "Tap 'Open Settings' then find and enable Groot in the Call Blocking list.",
                benefit: "stop spam before it rings"
            ),
            PermissionItem(
                type: .contacts,
                icon: "person.crop.circle.badge.checkmark",
                iconColor: .grootShield,
                title: "protect contacts",
                subtitle: "Allow access to add trusted contacts to your whitelist so their calls always get through.",
                benefit: "whitelist trusted callers"
            )
        ]
        
        // Check initial statuses
        Task {
            await checkAllPermissionStatuses()
        }
    }
    
    private func checkAllPermissionStatuses() async {
        for i in permissions.indices {
            let status = await checkPermissionStatus(permissions[i].type)
            await MainActor.run {
                permissions[i].status = status
            }
        }
    }
    
    private func checkPermissionStatus(_ type: PermissionType) async -> PermissionStatus {
        switch type {
        case .notifications:
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .authorized: return .granted
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            default: return .notDetermined
            }
            
        case .callBlocking:
            return await withCheckedContinuation { continuation in
                CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
                    withIdentifier: "com.reelsynth.Groot.CallDirectory"
                ) { status, _ in
                    switch status {
                    case .enabled: continuation.resume(returning: .granted)
                    case .disabled: continuation.resume(returning: .denied)
                    default: continuation.resume(returning: .notDetermined)
                    }
                }
            }
            
        case .contacts:
            let status = CNContactStore.authorizationStatus(for: .contacts)
            switch status {
            case .authorized: return .granted
            case .denied, .restricted: return .denied
            case .notDetermined: return .notDetermined
            @unknown default: return .notDetermined
            }
        }
    }
    
    private func handlePermission(allow: Bool) {
        guard !isProcessing else { return }
        
        if allow {
            let currentType = permissions[currentIndex].type
            
            // Call blocking is special - just opens settings, doesn't auto-advance
            if currentType == .callBlocking {
                openCallBlockingSettings()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    waitingForSettingsReturn = true
                }
                return
            }
            
            isProcessing = true
            Task {
                await requestPermission(currentType)
                await MainActor.run {
                    isProcessing = false
                    moveToNext()
                }
            }
        } else {
            moveToNext()
        }
    }
    
    private func requestPermission(_ type: PermissionType) async {
        switch type {
        case .notifications:
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                await MainActor.run {
                    permissions[currentIndex].status = granted ? .granted : .denied
                    if granted { GrootHaptics.success() } else { GrootHaptics.error() }
                }
            } catch {
                await MainActor.run {
                    permissions[currentIndex].status = .denied
                    GrootHaptics.error()
                }
            }
            
        case .callBlocking:
            // Handled separately in handlePermission
            break
            
        case .contacts:
            let store = CNContactStore()
            do {
                let granted = try await store.requestAccess(for: .contacts)
                await MainActor.run {
                    permissions[currentIndex].status = granted ? .granted : .denied
                    if granted { GrootHaptics.success() } else { GrootHaptics.error() }
                }
            } catch {
                await MainActor.run {
                    permissions[currentIndex].status = .denied
                    GrootHaptics.error()
                }
            }
        }
    }
    
    private func openCallBlockingSettings() {
        // Use the official CallKit API to open Call Blocking settings
        // This is the Apple-recommended way and won't cause App Store rejection
        // Note: This opens Phone settings, user needs to tap "Call Blocking & Identification"
        
        GrootHaptics.buttonPress()
        
        Task {
            do {
                // iOS 17+ async version
                try await CXCallDirectoryManager.sharedInstance.openSettings()
            } catch {
                // Fallback: Open Phone settings via URL scheme
                print("CXCallDirectoryManager.openSettings failed: \(error)")
                await MainActor.run {
                    openPhoneSettingsFallback()
                }
            }
        }
    }
    
    private func openPhoneSettingsFallback() {
        // Fallback to URL scheme if CallKit API fails
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
    
    private func moveToNext() {
        GrootHaptics.buttonPress()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentIndex < permissions.count - 1 {
                currentIndex += 1
                waitingForSettingsReturn = false
            } else {
                allPermissionsHandled = true
            }
        }
    }
}

// MARK: - Permission Models

enum PermissionType {
    case notifications
    case callBlocking
    case contacts
}

enum PermissionStatus {
    case notDetermined
    case granted
    case denied
}

struct PermissionItem: Identifiable {
    let id = UUID()
    let type: PermissionType
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let benefit: String
    var status: PermissionStatus = .notDetermined
}

// MARK: - Permissions Header (Duolingo-Style Progress)

struct PermissionsHeader: View {
    var currentIndex: Int
    var totalCount: Int
    
    private var progress: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(currentIndex + 1) / CGFloat(totalCount)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Duolingo-style progress bar
            DuoProgressBar(progress: progress, height: 16)
            
            HStack {
                Text("setup permissions")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                
                Spacer()
                
                Text("\(currentIndex + 1)/\(totalCount)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootShield)
            }
        }
    }
}

// MARK: - Duolingo-Style Progress Bar

struct DuoProgressBar: View {
    let progress: CGFloat
    let height: CGFloat
    
    // Duolingo colors
    private let trackColor = Color(red: 229/255, green: 229/255, blue: 229/255) // #E5E5E5
    private let fillColor = Color.grootShield
    private let highlightColor = Color.grootLeaf
    
    @State private var animatedProgress: CGFloat = 0
    @State private var showShine = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track (background)
                Capsule()
                    .fill(trackColor)
                    .frame(height: height)
                
                // Progress fill with 3D effect
                ZStack(alignment: .leading) {
                    // Main fill
                    Capsule()
                        .fill(fillColor)
                        .frame(width: max(height, geometry.size.width * animatedProgress), height: height)
                    
                    // Top highlight (gives 3D look)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [highlightColor.opacity(0.6), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: max(height, geometry.size.width * animatedProgress), height: height / 2)
                        .offset(y: -height / 4)
                        .clipShape(Capsule())
                    
                    // Shine effect on progress change
                    if showShine {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0), Color.white.opacity(0.4), Color.white.opacity(0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 40, height: height)
                            .offset(x: geometry.size.width * animatedProgress - 20)
                            .clipShape(Capsule())
                    }
                }
                .clipShape(Capsule())
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            // Animate progress change
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
            
            // Show shine effect when progress increases
            if newValue > oldValue {
                withAnimation(.easeOut(duration: 0.3)) {
                    showShine = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showShine = false
                    }
                }
            }
        }
    }
}

// MARK: - Permission Card View

struct PermissionCardView: View {
    let permission: PermissionItem
    
    @State private var showIcon = false
    @State private var showContent = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon with animated background
            ZStack {
                // Pulse rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(permission.iconColor.opacity(0.1), lineWidth: 2)
                        .frame(width: 180 + CGFloat(i * 30), height: 180 + CGFloat(i * 30))
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                            value: pulseAnimation
                        )
                }
                
                // Main circle
                Circle()
                    .fill(permission.iconColor.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .scaleEffect(showIcon ? 1 : 0.5)
                    .opacity(showIcon ? 1 : 0)
                
                // Icon
                Image(systemName: permission.icon)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(permission.iconColor)
                    .scaleEffect(showIcon ? 1 : 0.3)
                    .opacity(showIcon ? 1 : 0)
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(permission.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .multilineTextAlignment(.center)
                
                Text(permission.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // Benefit tag
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(permission.benefit)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundStyle(permission.iconColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(permission.iconColor.opacity(0.12))
            .clipShape(Capsule())
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.8)
        }
        .padding(.horizontal, 24)
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        showIcon = false
        showContent = false
        pulseAnimation = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showIcon = true
            }
            pulseAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Permissions Complete View

struct PermissionsCompleteView: View {
    @State private var showCheck = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            // Confetti
            ForEach(confetti) { piece in
                ConfettiView(piece: piece)
            }
            
            VStack(spacing: 32) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.grootShield.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(showCheck ? 1 : 0.5)
                        .opacity(showCheck ? 1 : 0)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundStyle(Color.grootShield)
                        .scaleEffect(showCheck ? 1 : 0.3)
                        .opacity(showCheck ? 1 : 0)
                }
                
                VStack(spacing: 12) {
                    Text("you're all set!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                    
                    Text("groot is ready to protect you\nfrom unwanted calls")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 15)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showCheck = true
            }
            GrootHaptics.success()
            spawnConfetti()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
    }
    
    private func spawnConfetti() {
        for i in 0..<30 {
            let piece = ConfettiPiece(
                id: i,
                color: [Color.grootShield, Color.grootSky, Color.grootSun, Color.grootFlame, Color.grootViolet].randomElement()!,
                x: CGFloat.random(in: -150...150),
                delay: Double.random(in: 0...0.3)
            )
            confetti.append(piece)
        }
    }
}

// MARK: - Confetti

struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(piece.color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .offset(
                x: piece.x,
                y: animate ? 400 : -200
            )
            .opacity(animate ? 0 : 1)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .onAppear {
                withAnimation(
                    .easeIn(duration: Double.random(in: 1.5...2.5))
                    .delay(piece.delay)
                ) {
                    animate = true
                }
            }
    }
}

// MARK: - Preview

#Preview("Permissions View") {
    PermissionsView(onComplete: {})
}

#Preview("Permission Card") {
    PermissionCardView(
        permission: PermissionItem(
            type: .notifications,
            icon: "bell.badge.fill",
            iconColor: .grootSun,
            title: "stay informed",
            subtitle: "Get notified when Groot blocks spam calls so you know you're protected.",
            benefit: "know when spam is blocked"
        )
    )
    .background(Color.grootSnow)
}

#Preview("Permissions Complete") {
    PermissionsCompleteView()
        .background(Color.grootSnow)
}
