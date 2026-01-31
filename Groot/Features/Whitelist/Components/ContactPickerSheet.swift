//
//  ContactPickerSheet.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Contact Picker Sheet

struct ContactPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSelect: (ContactInfo) -> Void
    
    @State private var contacts: [ContactInfo] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var hasPermission = false
    
    private var filteredContacts: [ContactInfo] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.phoneNumbers.contains { $0.contains(searchText) }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if !hasPermission {
                    permissionRequiredView
                } else if isLoading {
                    loadingView
                } else if contacts.isEmpty {
                    emptyStateView
                } else {
                    contactListView
                }
            }
            .navigationTitle("Select Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GrootCloseButton { dismiss() }
                }
            }
        }
        .task {
            await checkPermissionAndLoad()
        }
    }
    
    // MARK: - View Components
    
    private var permissionRequiredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(Color.grootSun)
            
            Text("Contacts Access Required")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            Text("Allow access to your contacts to add trusted numbers")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootStone)
                .multilineTextAlignment(.center)
            
            GrootButton("Allow Access", variant: .primary) {
                Task {
                    await requestPermission()
                }
            }
        }
        .padding(40)
    }
    
    private var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
    
    private var emptyStateView: some View {
        Text("No contacts with phone numbers found")
            .foregroundStyle(Color.grootStone)
    }
    
    private var contactListView: some View {
        List {
            ForEach(filteredContacts) { contact in
                Button {
                    onSelect(contact)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        ContactAvatar(name: contact.fullName, size: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.fullName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.grootBark)
                            
                            if let phone = contact.primaryPhoneNumber {
                                Text(PhoneNumberService.shared.formatForDisplay(phone))
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.grootStone)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.grootShield)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search contacts")
    }
    
    // MARK: - Actions
    
    private func checkPermissionAndLoad() async {
        hasPermission = ContactService.shared.hasAccess
        if hasPermission {
            await loadContacts()
        }
    }
    
    private func requestPermission() async {
        hasPermission = await ContactService.shared.requestAccess()
        if hasPermission {
            await loadContacts()
        }
    }
    
    private func loadContacts() async {
        isLoading = true
        do {
            contacts = try await ContactService.shared.fetchAllContacts()
        } catch {
            print("Failed to load contacts: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    ContactPickerSheet(onSelect: { _ in })
}
