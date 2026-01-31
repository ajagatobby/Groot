//
//  SettingsView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Settings View

struct SettingsView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    // MARK: - Data
    
    @Query private var settings: [AppSettings]
    
    // MARK: - ViewModel
    
    @State private var viewModel: SettingsViewModel?
    
    // MARK: - Computed Properties
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    callDirectorySection
                    blockingSection
                    preferencesSection
                    statisticsSection
                    aboutSection
                    openSourceCallout
                    
                    #if DEBUG
                    developerSection
                    #endif
                }
                .padding(20)
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
            }
            .alert("Reset Onboarding?", isPresented: Binding(
                get: { viewModel?.showResetAlert ?? false },
                set: { viewModel?.showResetAlert = $0 }
            )) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel?.resetOnboarding(settings: appSettings)
                }
            } message: {
                Text("The app will restart and show the welcome screen.")
            }
        }
        .grootToast(
            isPresented: Binding(
                get: { viewModel?.showToast ?? false },
                set: { viewModel?.showToast = $0 }
            ),
            message: viewModel?.toastMessage ?? ""
        )
        .task {
            await viewModel?.onAppear()
        }
        .onAppear {
            if viewModel == nil {
                let vm = SettingsViewModel(callBlockingService: callBlockingService)
                vm.configure(with: modelContext)
                viewModel = vm
            }
        }
    }
    
    // MARK: - View Sections
    
    private var callDirectorySection: some View {
        CallDirectoryStatusCard(
            status: viewModel?.extensionStatus ?? .unknown,
            isSyncing: viewModel?.isSyncing ?? false,
            onOpenSettings: {
                viewModel?.openCallBlockingSettings()
            },
            onSync: {
                viewModel?.syncCallDirectory()
            }
        )
        .grootAppear(delay: 0)
    }
    
    private var blockingSection: some View {
        GrootListSection("blocking") {
            GrootToggleRow(
                "block unknown callers",
                subtitle: "Automatically block numbers not in contacts",
                icon: "phone.down.fill",
                iconColor: .grootFlame,
                isOn: Binding(
                    get: { appSettings?.blockUnknownCallers ?? true },
                    set: { viewModel?.updateBlockUnknownCallers($0, settings: appSettings) }
                )
            )
            
            GrootListDivider()
            
            GrootToggleRow(
                "silent mode",
                subtitle: "Block without any notification",
                icon: "bell.slash.fill",
                iconColor: .grootSun,
                isOn: Binding(
                    get: { appSettings?.silentMode ?? false },
                    set: { viewModel?.updateSilentMode($0, settings: appSettings) }
                )
            )
        }
        .grootAppear(delay: 0.1)
    }
    
    private var preferencesSection: some View {
        GrootListSection("preferences") {
            GrootToggleRow(
                "notifications",
                icon: "bell.fill",
                iconColor: .grootSky,
                isOn: Binding(
                    get: { appSettings?.notificationsEnabled ?? true },
                    set: { viewModel?.updateNotificationsEnabled($0, settings: appSettings) }
                )
            )
            
            GrootListDivider()
            
            GrootToggleRow(
                "haptic feedback",
                icon: "waveform",
                iconColor: .grootViolet,
                isOn: Binding(
                    get: { appSettings?.hapticsEnabled ?? true },
                    set: { viewModel?.updateHapticsEnabled($0, settings: appSettings) }
                )
            )
        }
        .grootAppear(delay: 0.2)
    }
    
    private var statisticsSection: some View {
        GrootListSection("statistics") {
            GrootListItem(
                "blocked numbers",
                subtitle: "\(viewModel?.blockedNumbersCount ?? 0)",
                icon: "hand.raised.fill",
                iconColor: .grootFlame,
                accessory: .none
            )
            
            GrootListDivider()
            
            GrootListItem(
                "active patterns",
                subtitle: "\(viewModel?.patternsCount ?? 0)",
                icon: "number",
                iconColor: .grootViolet,
                accessory: .none
            )
            
            GrootListDivider()
            
            GrootListItem(
                "blocked countries",
                subtitle: "\(viewModel?.blockedCountriesCount ?? 0)",
                icon: "globe",
                iconColor: .grootSky,
                accessory: .none
            )
        }
        .grootAppear(delay: 0.3)
    }
    
    private var aboutSection: some View {
        GrootListSection("about") {
            GrootListItem(
                "version",
                subtitle: "1.0.0",
                icon: "info.circle.fill",
                iconColor: .grootStone,
                accessory: .none
            )
            
            GrootListDivider()
            
            GrootListItem(
                "privacy policy",
                icon: "hand.raised.fill",
                iconColor: .grootShield
            ) { }
            
            GrootListDivider()
            
            GrootListItem(
                "rate groot",
                icon: "star.fill",
                iconColor: .grootSun
            ) { }
        }
        .grootAppear(delay: 0.4)
    }
    
    private var openSourceCallout: some View {
        GrootCallout(
            title: "open source",
            message: "Groot is open source. View the code, contribute, or report issues on GitHub.",
            icon: "chevron.left.forwardslash.chevron.right",
            color: .grootViolet,
            action: { }
        )
        .grootAppear(delay: 0.5)
    }
    
    #if DEBUG
    private var developerSection: some View {
        GrootListSection("developer") {
            Button {
                viewModel?.showResetOnboardingAlert()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.grootFlame.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.grootFlame)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("reset onboarding")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.grootFlame)
                        
                        Text("Show welcome screen again")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
        }
        .grootAppear(delay: 0.6)
    }
    #endif
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
