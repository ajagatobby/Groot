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
    
    // MARK: - Environment
    
    @Environment(\.callBlockingService) private var callBlockingService
    
    // MARK: - Data
    
    @Query(sort: \BlockedNumber.blockedAt, order: .reverse)
    private var blockedNumbers: [BlockedNumber]
    
    @Query private var blockedCountries: [BlockedCountry]
    
    // MARK: - ViewModel
    
    @State private var viewModel: HomeViewModel?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    extensionStatusBanner
                    
                    BlockedStatsCard(
                        totalBlocked: blockedNumbers.count,
                        blockedToday: viewModel?.blockedToday(from: blockedNumbers) ?? 0,
                        blockedThisWeek: viewModel?.blockedThisWeek(from: blockedNumbers) ?? 0,
                        topBlockedCountry: viewModel?.topBlockedCountry(from: blockedCountries)
                    )
                    .grootAppear(delay: 0)
                    
                    if blockedNumbers.isEmpty {
                        GrootEmptyState.noBlockedNumbers {
                            viewModel?.openBlockSheet()
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
                        viewModel?.openBlockSheet()
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showBlockSheet ?? false },
            set: { viewModel?.showBlockSheet = $0 }
        )) {
            AddBlockNumberSheet()
                .presentationDetents([.medium])
        }
        .grootToast(
            isPresented: Binding(
                get: { viewModel?.showToast ?? false },
                set: { viewModel?.showToast = $0 }
            ),
            message: viewModel?.toastMessage ?? ""
        )
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(callBlockingService: callBlockingService)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var extensionStatusBanner: some View {
        if viewModel?.isExtensionDisabled == true {
            GrootBanner(
                "Enable call blocking in Settings to protect your phone",
                variant: .warning,
                icon: "exclamationmark.triangle.fill",
                action: .init(title: "Enable", action: {
                    viewModel?.openCallBlockingSettings()
                })
            )
            .grootAppear(delay: 0)
        }
    }
    
    @ViewBuilder
    private var recentBlocksSection: some View {
        let recentBlocks = viewModel?.recentBlocks(from: blockedNumbers) ?? []
        
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
            ForEach(recentBlocks) { blocked in
                BlockedNumberRow(
                    blockedNumber: blocked,
                    onUnblock: { viewModel?.unblockNumber(blocked) },
                    onViewDetails: { }
                )
                
                if blocked.id != recentBlocks.last?.id {
                    Divider().padding(.leading, 78)
                }
            }
        }
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .grootAppear(delay: 0.2)
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
