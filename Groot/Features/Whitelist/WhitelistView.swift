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
    
    // MARK: - Environment
    
    @Environment(\.callBlockingService) private var callBlockingService
    
    // MARK: - Data
    
    @Query(sort: \WhitelistContact.addedAt, order: .reverse)
    private var whitelistContacts: [WhitelistContact]
    
    // MARK: - ViewModel
    
    @State private var viewModel: WhitelistViewModel?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    WhitelistStatsRow(
                        totalContacts: whitelistContacts.count,
                        callsAllowed: viewModel?.totalCallsAllowed(from: whitelistContacts) ?? 0
                    )
                    .grootAppear(delay: 0)
                    
                    AddWhitelistContactCard(
                        onAddFromContacts: { viewModel?.openContactPicker() },
                        onAddManually: { viewModel?.openManualEntry() }
                    )
                    .grootAppear(delay: 0.1)
                    
                    if whitelistContacts.isEmpty {
                        GrootEmptyState.noWhitelistContacts {
                            viewModel?.openManualEntry()
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
                        viewModel?.openManualEntry()
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showContactPicker ?? false },
            set: { viewModel?.showContactPicker = $0 }
        )) {
            ContactPickerSheet(onSelect: { contact in
                viewModel?.addContactToWhitelist(contact)
            })
            .presentationDetents([.large])
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showManualEntry ?? false },
            set: { viewModel?.showManualEntry = $0 }
        )) {
            AddWhitelistManualSheet()
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
                viewModel = WhitelistViewModel(callBlockingService: callBlockingService)
            }
        }
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
            ForEach(whitelistContacts) { contact in
                WhitelistContactRow(
                    name: contact.name,
                    phoneNumber: PhoneNumberService.shared.formatForDisplay(contact.phoneNumber),
                    contactImage: nil,
                    addedDate: contact.addedAt,
                    callsAllowed: contact.callsAllowed,
                    onRemove: { viewModel?.removeFromWhitelist(contact) },
                    onViewDetails: { }
                )
                
                if contact.id != whitelistContacts.last?.id {
                    Divider().padding(.leading, 78)
                }
            }
        }
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .grootAppear(delay: 0.3)
    }
}

// MARK: - Preview

#Preview {
    WhitelistView()
        .modelContainer(for: WhitelistContact.self, inMemory: true)
}
