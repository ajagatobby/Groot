//
//  SettingsViewModel.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData
import Observation

// MARK: - Settings ViewModel

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Dependencies
    
    private let callBlockingService: CallBlockingService
    private var modelContext: ModelContext?
    
    // MARK: - UI State
    
    var showResetAlert = false
    var isSyncing = false
    var showToast = false
    var toastMessage = ""
    
    // MARK: - Statistics (cached from service)
    
    var blockedNumbersCount: Int { callBlockingService.blockedNumbersCount }
    var patternsCount: Int { callBlockingService.patternsCount }
    var blockedCountriesCount: Int { callBlockingService.blockedCountriesCount }
    var extensionStatus: CallBlockingService.ExtensionStatus { callBlockingService.extensionStatus }
    
    // MARK: - Initialization
    
    init(callBlockingService: CallBlockingService) {
        self.callBlockingService = callBlockingService
    }
    
    // MARK: - Configuration
    
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Actions
    
    func onAppear() async {
        await callBlockingService.checkExtensionStatus()
        await callBlockingService.refreshStats()
    }
    
    func openCallBlockingSettings() {
        callBlockingService.openCallBlockingSettings()
    }
    
    func syncCallDirectory() {
        isSyncing = true
        Task {
            do {
                try await callBlockingService.reloadCallDirectory()
                toastMessage = "Sync complete!"
                showToast = true
                GrootHaptics.success()
            } catch {
                toastMessage = "Sync failed"
                showToast = true
                GrootHaptics.error()
            }
            isSyncing = false
        }
    }
    
    func showResetOnboardingAlert() {
        showResetAlert = true
    }
    
    func resetOnboarding(settings: AppSettings?) {
        guard let settings = settings, let modelContext = modelContext else { return }
        
        settings.hasCompletedOnboarding = false
        settings.onboardingCompletedAt = nil
        try? modelContext.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exit(0)
        }
    }
    
    // MARK: - Settings Bindings
    
    func updateBlockUnknownCallers(_ value: Bool, settings: AppSettings?) {
        guard let modelContext = modelContext else { return }
        settings?.blockUnknownCallers = value
        AppGroupContainer.blockUnknownCallers = value
        try? modelContext.save()
    }
    
    func updateSilentMode(_ value: Bool, settings: AppSettings?) {
        guard let modelContext = modelContext else { return }
        settings?.silentMode = value
        try? modelContext.save()
    }
    
    func updateNotificationsEnabled(_ value: Bool, settings: AppSettings?) {
        guard let modelContext = modelContext else { return }
        settings?.notificationsEnabled = value
        try? modelContext.save()
    }
    
    func updateHapticsEnabled(_ value: Bool, settings: AppSettings?) {
        guard let modelContext = modelContext else { return }
        settings?.hapticsEnabled = value
        try? modelContext.save()
    }
}
