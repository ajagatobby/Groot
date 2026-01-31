//
//  WhitelistViewModel.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData
import Observation

// MARK: - Whitelist ViewModel

@MainActor
@Observable
final class WhitelistViewModel {
    
    // MARK: - Dependencies
    
    private let callBlockingService: CallBlockingService
    
    // MARK: - UI State
    
    var showContactPicker = false
    var showManualEntry = false
    var showToast = false
    var toastMessage = ""
    var contacts: [ContactInfo] = []
    var isLoadingContacts = false
    
    // MARK: - Initialization
    
    init(callBlockingService: CallBlockingService) {
        self.callBlockingService = callBlockingService
    }
    
    // MARK: - Computed Properties
    
    func totalCallsAllowed(from whitelistContacts: [WhitelistContact]) -> Int {
        whitelistContacts.reduce(0) { $0 + $1.callsAllowed }
    }
    
    // MARK: - Actions
    
    func openContactPicker() {
        showContactPicker = true
    }
    
    func openManualEntry() {
        showManualEntry = true
    }
    
    func removeFromWhitelist(_ contact: WhitelistContact) {
        do {
            try callBlockingService.removeFromWhitelist(contact.phoneNumber)
            toastMessage = "Contact removed"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to remove"
            showToast = true
            GrootHaptics.error()
        }
    }
    
    func addContactToWhitelist(_ contact: ContactInfo) {
        guard let phoneNumber = contact.primaryPhoneNumber else { return }
        
        do {
            try callBlockingService.addToWhitelist(
                name: contact.fullName,
                phoneNumber: phoneNumber,
                contactIdentifier: contact.id
            )
            toastMessage = "Contact added!"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = error.localizedDescription
            showToast = true
            GrootHaptics.error()
        }
    }
}
