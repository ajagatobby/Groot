//
//  AddBlockNumberSheet.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Add Block Number Sheet

struct AddBlockNumberSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.callBlockingService) private var callBlockingService
    
    @State private var phoneNumber = ""
    @State private var countryCode = "+1"
    @State private var label = ""
    @State private var isBlocking = false
    @State private var errorMessage: String?
    
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
                    GrootCloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.grootFlame)
            
            GrootText("block a number", style: .title)
            
            Text("this number will be blocked from calling you")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootStone)
        }
        .padding(.top, 8)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            GrootPhoneField(
                phoneNumber: $phoneNumber,
                countryCode: countryCode,
                onCountryTap: { }
            )
            
            GrootTextField(
                "label (optional)",
                text: $label,
                icon: "tag.fill"
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootFlame)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GrootButton(
                "block this number",
                variant: .danger,
                icon: "hand.raised.fill",
                isDisabled: phoneNumber.isEmpty,
                isLoading: isBlocking
            ) {
                blockNumber()
            }
        }
    }
    
    // MARK: - Actions
    
    private func blockNumber() {
        isBlocking = true
        errorMessage = nil
        
        let fullNumber = countryCode + phoneNumber
        
        do {
            try callBlockingService.blockNumber(
                fullNumber,
                reason: .manual,
                label: label.isEmpty ? nil : label
            )
            
            GrootHaptics.blockConfirmed()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isBlocking = false
            GrootHaptics.error()
        }
    }
}

// MARK: - Preview

#Preview {
    AddBlockNumberSheet()
}
