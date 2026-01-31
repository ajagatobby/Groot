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
    @State private var previousTab = 0
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
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
        }
    }
    
    // MARK: - View Components
    
    /// Maintains all views in memory to preserve animation state
    private var tabContent: some View {
        ZStack {
            TabContentView(index: 0, selectedTab: selectedTab, previousTab: previousTab) {
                HomeView()
            }
            
            TabContentView(index: 1, selectedTab: selectedTab, previousTab: previousTab) {
                PatternsTabView()
            }
            
            TabContentView(index: 2, selectedTab: selectedTab, previousTab: previousTab) {
                CountriesView()
            }
            
            TabContentView(index: 3, selectedTab: selectedTab, previousTab: previousTab) {
                SettingsView()
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

// MARK: - Tab Content View

/// Animated container for tab content with scale and fade transitions
struct TabContentView<Content: View>: View {
    let index: Int
    let selectedTab: Int
    let previousTab: Int
    @ViewBuilder let content: () -> Content
    
    private var isSelected: Bool { index == selectedTab }
    private var wasSelected: Bool { index == previousTab }
    
    // Determine slide direction based on tab indices
    private var slideDirection: CGFloat {
        if isSelected {
            return selectedTab > previousTab ? 1 : -1
        } else if wasSelected {
            return selectedTab > previousTab ? -1 : 1
        }
        return 0
    }
    
    var body: some View {
        content()
            .opacity(isSelected ? 1 : 0)
            .scaleEffect(isSelected ? 1 : 0.96)
            .offset(x: isSelected ? 0 : slideDirection * 20)
            .zIndex(isSelected ? 1 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
            .allowsHitTesting(isSelected)
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
