//
//  HomeView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Home View

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    @Query(sort: \BlockedNumber.blockedAt, order: .reverse)
    private var blockedNumbers: [BlockedNumber]
    
    @Query private var blockedCountries: [BlockedCountry]
    
    @State private var showBlockSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // MARK: - Computed Properties
    
    private var totalBlocked: Int { blockedNumbers.count }
    
    private var blockedToday: Int {
        let calendar = Calendar.current
        return blockedNumbers.filter { calendar.isDateInToday($0.blockedAt) }.count
    }
    
    private var blockedThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return blockedNumbers.filter { $0.blockedAt >= weekAgo }.count
    }
    
    private var topBlockedCountry: String? {
        guard !blockedCountries.isEmpty else { return nil }
        return blockedCountries.max(by: { $0.callsBlocked < $1.callsBlocked })?.flag
    }
    
    private var recentBlocks: [BlockedNumber] {
        Array(blockedNumbers.prefix(5))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    extensionStatusBanner
                    
                    BlockedStatsCard(
                        totalBlocked: totalBlocked,
                        blockedToday: blockedToday,
                        blockedThisWeek: blockedThisWeek,
                        topBlockedCountry: topBlockedCountry
                    )
                    .grootAppear(delay: 0)
                    
                    if blockedNumbers.isEmpty {
                        GrootEmptyState.noBlockedNumbers {
                            showBlockSheet = true
                        }
                        .grootAppear(delay: 0.1)
                    } else {
                        recentBlocksSection
                    }
                    
                    GrootCallout(
                        title: "protect your privacy",
                        message: "Groot never uploads your data. All call blocking happens on your device.",
                        icon: "lock.shield.fill",
                        color: .grootShield
                    )
                    .grootAppear(delay: 0.3)
                }
                .padding(20)
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("groot")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.grootBark)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    GrootIconButton("plus", variant: .primary, size: .small) {
                        showBlockSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showBlockSheet) {
            AddBlockNumberSheet()
                .presentationDetents([.medium])
        }
        .grootToast(isPresented: $showToast, message: toastMessage)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var extensionStatusBanner: some View {
        if !callBlockingService.extensionStatus.isEnabled && callBlockingService.extensionStatus != .unknown {
            GrootBanner(
                "Enable call blocking in Settings to protect your phone",
                variant: .warning,
                icon: "exclamationmark.triangle.fill",
                action: .init(title: "Enable", action: {
                    callBlockingService.openCallBlockingSettings()
                })
            )
            .grootAppear(delay: 0)
        }
    }
    
    @ViewBuilder
    private var recentBlocksSection: some View {
        HStack {
            GrootText("recent blocks", style: .heading)
            Spacer()
            if blockedNumbers.count > 5 {
                Button {
                    // View all - could navigate to full list
                } label: {
                    Text("view all")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootSky)
                }
            }
        }
        .grootAppear(delay: 0.1)
        
        VStack(spacing: 0) {
            ForEach(Array(recentBlocks.enumerated()), id: \.element.id) { index, blocked in
                BlockedNumberRow(
                    blockedNumber: blocked,
                    onUnblock: { unblockNumber(blocked) },
                    onViewDetails: { }
                )
                
                if index < recentBlocks.count - 1 {
                    Divider().padding(.leading, 78)
                }
            }
        }
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .grootAppear(delay: 0.2)
    }
    
    // MARK: - Actions
    
    private func unblockNumber(_ blocked: BlockedNumber) {
        do {
            try callBlockingService.unblockNumber(blocked.phoneNumber)
            toastMessage = "Number unblocked!"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to unblock"
            showToast = true
            GrootHaptics.error()
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [
            BlockedNumber.self,
            BlockedCountry.self
        ], inMemory: true)
}
