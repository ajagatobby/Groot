//
//  WhitelistView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Whitelist View

struct WhitelistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    @Query(sort: \WhitelistContact.addedAt, order: .reverse)
    private var whitelistContacts: [WhitelistContact]
    
    @State private var showContactPicker = false
    @State private var showManualEntry = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var contacts: [ContactInfo] = []
    @State private var isLoadingContacts = false
    
    private var totalCallsAllowed: Int {
        whitelistContacts.reduce(0) { $0 + $1.callsAllowed }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WhitelistStatsRow(
                        totalContacts: whitelistContacts.count,
                        callsAllowed: totalCallsAllowed
                    )
                    .grootAppear(delay: 0)
                    
                    AddWhitelistContactCard(
                        onAddFromContacts: { showContactPicker = true },
                        onAddManually: { showManualEntry = true }
                    )
                    .grootAppear(delay: 0.1)
                    
                    if whitelistContacts.isEmpty {
                        GrootEmptyState.noWhitelistContacts {
                            showManualEntry = true
                        }
                        .grootAppear(delay: 0.2)
                    } else {
                        trustedContactsSection
                    }
                }
                .padding(20)
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("whitelist")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    GrootIconButton("plus", variant: .primary, size: .small) {
                        showManualEntry = true
                    }
                }
            }
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPickerSheet(onSelect: { contact in
                addContactToWhitelist(contact)
            })
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showManualEntry) {
            AddWhitelistManualSheet()
                .presentationDetents([.medium])
        }
        .grootToast(isPresented: $showToast, message: toastMessage)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var trustedContactsSection: some View {
        HStack {
            GrootText("trusted contacts", style: .heading)
            Spacer()
        }
        .grootAppear(delay: 0.2)
        
        VStack(spacing: 0) {
            ForEach(Array(whitelistContacts.enumerated()), id: \.element.id) { index, contact in
                WhitelistContactRow(
                    name: contact.name,
                    phoneNumber: PhoneNumberService.shared.formatForDisplay(contact.phoneNumber),
                    contactImage: nil,
                    addedDate: contact.addedAt,
                    callsAllowed: contact.callsAllowed,
                    onRemove: { removeFromWhitelist(contact) },
                    onViewDetails: { }
                )
                
                if index < whitelistContacts.count - 1 {
                    Divider().padding(.leading, 78)
                }
            }
        }
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .grootAppear(delay: 0.3)
    }
    
    // MARK: - Actions
    
    private func removeFromWhitelist(_ contact: WhitelistContact) {
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
    
    private func addContactToWhitelist(_ contact: ContactInfo) {
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

// MARK: - Preview

#Preview {
    WhitelistView()
        .modelContainer(for: WhitelistContact.self, inMemory: true)
}
