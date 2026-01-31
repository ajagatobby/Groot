//
//  RootView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

enum AppScreen: Equatable {
    case splash
    case onboarding
    case permissions
    case main
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    
    @State private var currentScreen: AppScreen = .splash
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashView()
                    .transition(.opacity)
                
            case .onboarding:
                WelcomeView(onComplete: completeOnboarding)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .permissions:
                PermissionsView(onComplete: completePermissions)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .main:
                ContentView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentScreen)
        .onAppear {
            setupAppSettings()
        }
    }
    
    private func setupAppSettings() {
        // Check if settings exist, create if not
        if settings.isEmpty {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        } else if let existingSettings = appSettings {
            existingSettings.incrementLaunchCount()
            try? modelContext.save()
        }
        
        // Determine which screen to show
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            determineInitialScreen()
        }
    }
    
    private func determineInitialScreen() {
        guard let settings = appSettings else {
            currentScreen = .onboarding
            return
        }
        
        if !settings.hasCompletedOnboarding {
            currentScreen = .onboarding
        } else if !settings.hasCompletedPermissions {
            currentScreen = .permissions
        } else {
            currentScreen = .main
        }
    }
    
    private func completeOnboarding() {
        if let settings = appSettings {
            settings.completeOnboarding()
            try? modelContext.save()
        }
        
        currentScreen = .permissions
    }
    
    private func completePermissions() {
        if let settings = appSettings {
            settings.completePermissions()
            try? modelContext.save()
        }
        
        currentScreen = .main
    }
}

// MARK: - Splash View

struct SplashView: View {
    @State private var showMascot = false
    @State private var showTitle = false
    
    var body: some View {
        ZStack {
            Color.grootSnow
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                GrootMascotFallback(size: 120, mood: .idle)
                    .scaleEffect(showMascot ? 1 : 0.5)
                    .opacity(showMascot ? 1 : 0)
                
                Text("groot")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.grootBark)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMascot = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showTitle = true
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
