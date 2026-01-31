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
    @State private var selectedCountry: Country
    @State private var isAdding = false
    @State private var errorMessage: String?
    @State private var showCountryPicker = false
    
    private let countryService = CountryDataService.shared
    
    init() {
        // Initialize with user's current region or default to US
        let initialCountry = CountryDataService.shared.currentRegionCountry 
            ?? CountryDataService.shared.country(forISOCode: "US")!
        _selectedCountry = State(initialValue: initialCountry)
    }
    
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
            .sheet(isPresented: $showCountryPicker) {
                CountryCodePickerSheet(selectedCountry: $selectedCountry)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
                countryCode: selectedCountry.callingCode,
                countryFlag: selectedCountry.flag,
                onCountryTap: {
                    showCountryPicker = true
                }
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
        
        let fullNumber = selectedCountry.callingCode + phoneNumber
        
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
