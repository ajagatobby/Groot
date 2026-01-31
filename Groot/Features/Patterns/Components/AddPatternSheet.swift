//
//  AddPatternSheet.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Add Pattern Sheet

struct AddPatternSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.callBlockingService) private var callBlockingService
    
    @State private var pattern = ""
    @State private var patternDescription = ""
    @State private var isAdding = false
    @State private var errorMessage: String?
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case pattern
        case description
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                formSection
                examplesSection
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
            ZStack {
                Circle()
                    .fill(Color.grootViolet.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "number")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.grootViolet)
            }
            
            GrootText("create pattern", style: .title)
            
            Text("block numbers matching a specific pattern")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootStone)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("pattern")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                
                PatternTextField(
                    text: $pattern,
                    placeholder: "+1800*",
                    isFocused: focusedField == .pattern
                )
                .focused($focusedField, equals: .pattern)
            }
            
            GrootTextField(
                "description",
                text: $patternDescription,
                icon: "text.alignleft"
            )
            
            if let error = errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                    Text(error.lowercased())
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundStyle(Color.grootFlame)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            GrootButton(
                "create pattern",
                variant: .primary,
                icon: "plus.circle.fill",
                isDisabled: !isValidPattern,
                isLoading: isAdding
            ) {
                addPattern()
            }
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pattern examples")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.grootStone)
            
            VStack(spacing: 8) {
                PatternExampleRow(
                    pattern: "+1800*",
                    description: "All 1-800 toll-free numbers",
                    onTap: {
                        pattern = "+1800"
                        patternDescription = "Toll-free 1-800 numbers"
                    }
                )
                
                PatternExampleRow(
                    pattern: "+1*5551234",
                    description: "Specific number from any area code",
                    onTap: {
                        pattern = "+1*5551234"
                        patternDescription = "Number 555-1234 from any area code"
                    }
                )
                
                PatternExampleRow(
                    pattern: "+44*",
                    description: "All numbers from UK (+44)",
                    onTap: {
                        pattern = "+44"
                        patternDescription = "All UK numbers"
                    }
                )
            }
        }
        .padding(16)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed Properties
    
    private var isValidPattern: Bool {
        !pattern.isEmpty && !patternDescription.isEmpty
    }
    
    // MARK: - Actions
    
    private func addPattern() {
        isAdding = true
        errorMessage = nil
        
        // Normalize pattern - add + if needed
        var normalizedPattern = pattern.trimmingCharacters(in: .whitespaces)
        if !normalizedPattern.hasPrefix("+") && normalizedPattern.first?.isNumber == true {
            normalizedPattern = "+" + normalizedPattern
        }
        
        // Add wildcard if not present
        if !normalizedPattern.contains("*") {
            normalizedPattern += "*"
        }
        
        do {
            try callBlockingService.addPattern(normalizedPattern, description: patternDescription)
            
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
            
            dismiss()
        } catch {
            withAnimation(.grootSnappy) {
                errorMessage = error.localizedDescription
            }
            isAdding = false
            GrootHaptics.error()
        }
    }
}

// MARK: - Pattern Text Field

struct PatternTextField: View {
    @Binding var text: String
    let placeholder: String
    let isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "number")
                .foregroundStyle(isFocused ? Color.grootViolet : Color.grootPebble)
                .font(.system(size: 18, weight: .medium))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.grootBark)
                .keyboardType(.phonePad)
            
            if !text.isEmpty {
                Text("*")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.grootViolet)
                
                Button {
                    withAnimation(.grootSnappy) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.grootPebble)
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.grootCloud)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.grootViolet : Color.grootMist, lineWidth: 2)
        )
        .animation(.grootSnappy, value: isFocused)
    }
}

// MARK: - Pattern Example Row

struct PatternExampleRow: View {
    let pattern: String
    let description: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(pattern)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.grootViolet)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.grootViolet.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text(description.lowercased())
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "arrow.up.left.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.grootPebble)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    AddPatternSheet()
}
