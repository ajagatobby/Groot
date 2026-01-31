//
//  HomeViewModel.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData
import Observation

// MARK: - Home ViewModel

@MainActor
@Observable
final class HomeViewModel {
    
    // MARK: - Dependencies
    
    private let callBlockingService: CallBlockingService
    
    // MARK: - UI State
    
    var showBlockSheet = false
    var showToast = false
    var toastMessage = ""
    
    // MARK: - Initialization
    
    init(callBlockingService: CallBlockingService) {
        self.callBlockingService = callBlockingService
    }
    
    // MARK: - Computed Properties
    
    func blockedToday(from blockedNumbers: [BlockedNumber]) -> Int {
        let calendar = Calendar.current
        return blockedNumbers.filter { calendar.isDateInToday($0.blockedAt) }.count
    }
    
    func blockedThisWeek(from blockedNumbers: [BlockedNumber]) -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return blockedNumbers.filter { $0.blockedAt >= weekAgo }.count
    }
    
    func topBlockedCountry(from blockedCountries: [BlockedCountry]) -> String? {
        guard !blockedCountries.isEmpty else { return nil }
        return blockedCountries.max(by: { $0.callsBlocked < $1.callsBlocked })?.flag
    }
    
    func recentBlocks(from blockedNumbers: [BlockedNumber]) -> [BlockedNumber] {
        Array(blockedNumbers.prefix(5))
    }
    
    // MARK: - Extension Status
    
    var isExtensionDisabled: Bool {
        !callBlockingService.extensionStatus.isEnabled && 
        callBlockingService.extensionStatus != .unknown
    }
    
    // MARK: - Actions
    
    func openBlockSheet() {
        showBlockSheet = true
    }
    
    func openCallBlockingSettings() {
        callBlockingService.openCallBlockingSettings()
    }
    
    func unblockNumber(_ blocked: BlockedNumber) {
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
