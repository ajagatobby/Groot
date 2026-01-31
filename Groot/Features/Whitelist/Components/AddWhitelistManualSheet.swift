//
//  AddWhitelistManualSheet.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Add Whitelist Manual Sheet

struct AddWhitelistManualSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.callBlockingService) private var callBlockingService
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var countryCode = "+1"
    @State private var isAdding = false
    @State private var errorMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                formSection
                Spacer()
            }
            .padding(20)
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GrootCloseButton { dismiss() }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.grootShield)
            
            GrootText("add trusted contact", style: .title)
            
            Text("this contact will always get through")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootStone)
        }
        .padding(.top, 8)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            GrootTextField(
                "name",
                text: $name,
                icon: "person.fill"
            )
            
            GrootPhoneField(
                phoneNumber: $phoneNumber,
                countryCode: countryCode,
                onCountryTap: { }
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootFlame)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GrootButton(
                "add to whitelist",
                variant: .primary,
                icon: "checkmark.shield.fill",
                isDisabled: name.isEmpty || phoneNumber.isEmpty,
                isLoading: isAdding
            ) {
                addContact()
            }
        }
    }
    
    // MARK: - Actions
    
    private func addContact() {
        isAdding = true
        errorMessage = nil
        
        let fullNumber = countryCode + phoneNumber
        
        do {
            try callBlockingService.addToWhitelist(
                name: name,
                phoneNumber: fullNumber
            )
            
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isAdding = false
            GrootHaptics.error()
        }
    }
}

// MARK: - Preview

#Preview {
    AddWhitelistManualSheet()
}
