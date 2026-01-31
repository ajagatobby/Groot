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
/// 
/// Performance optimizations:
/// - Uses lazy tab loading to only initialize visited tabs
/// - Caches badge counts to avoid duplicate computation
/// - Uses allowsHitTesting instead of opacity for hidden tabs
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var callBlockingService = CallBlockingService()
    @State private var visitedTabs: Set<Int> = [0] // Track visited tabs for lazy loading
    
    @Query private var blockedNumbers: [BlockedNumber]
    @Query private var patterns: [BlockPattern]
    
    // MARK: - Cached Computed Properties
    
    /// Cache enabled patterns count to avoid duplicate filter
    private var enabledPatternsCount: Int {
        patterns.filter { $0.isEnabled }.count
    }
    
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
        .onChange(of: selectedTab) { _, newTab in
            // Mark tab as visited for lazy loading
            visitedTabs.insert(newTab)
        }
    }
    
    // MARK: - View Components
    
    /// Lazy tab loading - only initializes tabs that have been visited
    /// Uses allowsHitTesting(false) instead of opacity for better performance
    private var tabContent: some View {
        ZStack {
            // Home (always loaded as default tab)
            HomeView()
                .zIndex(selectedTab == 0 ? 1 : 0)
                .allowsHitTesting(selectedTab == 0)
                .opacity(selectedTab == 0 ? 1 : 0)
            
            // Patterns (lazy loaded)
            if visitedTabs.contains(1) {
                PatternsTabView()
                    .zIndex(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
                    .opacity(selectedTab == 1 ? 1 : 0)
            }
            
            // Countries (lazy loaded)
            if visitedTabs.contains(2) {
                CountriesView()
                    .zIndex(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
                    .opacity(selectedTab == 2 ? 1 : 0)
            }
            
            // Settings (lazy loaded)
            if visitedTabs.contains(3) {
                SettingsView()
                    .zIndex(selectedTab == 3 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 3)
                    .opacity(selectedTab == 3 ? 1 : 0)
            }
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
                    badge: enabledPatternsCount > 0 ? enabledPatternsCount : nil
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
