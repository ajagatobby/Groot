//
//  ContentView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Content View

/// Main tab-based navigation container for the Groot app.
/// This view manages the bottom tab bar and displays the appropriate
/// feature view based on the selected tab.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var callBlockingService = CallBlockingService()
    
    @Query private var blockedNumbers: [BlockedNumber]
    @Query private var patterns: [BlockPattern]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            tabContent
            tabBar
        }
        .background(Color.grootCloud)
        .environment(\.callBlockingService, callBlockingService)
        .onAppear {
            callBlockingService.configure(with: modelContext)
        }
    }
    
    // MARK: - View Components
    
    /// Maintains all views in memory to preserve state
    private var tabContent: some View {
        ZStack {
            HomeView()
                .opacity(selectedTab == 0 ? 1 : 0)
                .zIndex(selectedTab == 0 ? 1 : 0)
            
            PatternsTabView()
                .opacity(selectedTab == 1 ? 1 : 0)
                .zIndex(selectedTab == 1 ? 1 : 0)
            
            CountriesView()
                .opacity(selectedTab == 2 ? 1 : 0)
                .zIndex(selectedTab == 2 ? 1 : 0)
            
            SettingsView()
                .opacity(selectedTab == 3 ? 1 : 0)
                .zIndex(selectedTab == 3 ? 1 : 0)
        }
    }
    
    private var tabBar: some View {
        GrootTabBar(
            selectedTab: $selectedTab,
            tabs: [
                .init(
                    icon: "shield",
                    selectedIcon: "shield.fill",
                    label: "blocked",
                    badge: blockedNumbers.isEmpty ? nil : blockedNumbers.count
                ),
                .init(
                    icon: "number",
                    selectedIcon: "number.square.fill",
                    label: "patterns",
                    badge: patterns.filter { $0.isEnabled }.count > 0 ? patterns.filter { $0.isEnabled }.count : nil
                ),
                .init(
                    icon: "globe",
                    selectedIcon: "globe",
                    label: "countries"
                ),
                .init(
                    icon: "gearshape",
                    selectedIcon: "gearshape.fill",
                    label: "settings"
                )
            ]
        )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [
            AppSettings.self,
            BlockedNumber.self,
            WhitelistContact.self,
            BlockedCountry.self,
            BlockPattern.self
        ], inMemory: true)
}
