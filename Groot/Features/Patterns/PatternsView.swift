//
//  PatternsView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Patterns View

struct PatternsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    @Query(sort: \BlockPattern.createdAt, order: .reverse)
    private var patterns: [BlockPattern]
    
    @State private var showAddSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    private var filteredPatterns: [BlockPattern] {
        if searchText.isEmpty {
            return patterns
        }
        return patterns.filter {
            $0.pattern.localizedCaseInsensitiveContains(searchText) ||
            $0.patternDescription.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var enabledCount: Int {
        patterns.filter { $0.isEnabled }.count
    }
    
    private var totalMatches: Int {
        patterns.reduce(0) { $0 + $1.matchCount }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if !patterns.isEmpty {
                        statsSection
                        searchSection
                    }
                    
                    if patterns.isEmpty {
                        GrootEmptyState.noPatterns {
                            showAddSheet = true
                        }
                        .grootAppear(delay: 0)
                    } else if filteredPatterns.isEmpty {
                        GrootEmptyState.searchNoResults(query: searchText)
                            .grootAppear(delay: 0)
                    } else {
                        patternsListSection
                    }
                    
                    suggestedPatternsSection
                    
                    infoCallout
                }
                .padding(20)
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    GrootBackButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("pattern blocking")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    GrootIconButton("plus", variant: .primary, size: .small) {
                        showAddSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPatternSheet()
                .presentationDetents([.medium, .large])
        }
        .grootToast(isPresented: $showToast, message: toastMessage)
    }
    
    // MARK: - View Components
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            PatternStatCard(
                icon: "number",
                value: "\(patterns.count)",
                label: "patterns",
                color: .grootViolet
            )
            
            PatternStatCard(
                icon: "checkmark.circle.fill",
                value: "\(enabledCount)",
                label: "active",
                color: .grootShield
            )
            
            PatternStatCard(
                icon: "phone.down.fill",
                value: "\(totalMatches)",
                label: "blocked",
                color: .grootFlame
            )
        }
        .grootAppear(delay: 0)
    }
    
    private var searchSection: some View {
        GrootSearchField("search patterns", text: $searchText)
            .grootAppear(delay: 0.1)
    }
    
    private var patternsListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GrootText("your patterns", style: .heading)
                Spacer()
                Text("\(filteredPatterns.count) pattern\(filteredPatterns.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            .grootAppear(delay: 0.1)
            
            VStack(spacing: 0) {
                ForEach(filteredPatterns) { pattern in
                    PatternRow(
                        pattern: pattern,
                        onToggle: { togglePattern(pattern) },
                        onDelete: { deletePattern(pattern) }
                    )
                    
                    if pattern.id != filteredPatterns.last?.id {
                        Divider().padding(.leading, 70)
                    }
                }
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .grootAppear(delay: 0.2)
        }
    }
    
    private var suggestedPatternsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GrootText("suggested patterns", style: .heading)
                .grootAppear(delay: 0.3)
            
            VStack(spacing: 0) {
                let suggestions = availableSuggestions
                ForEach(suggestions.indices, id: \.self) { index in
                    let suggestion = suggestions[index]
                    SuggestedPatternRow(
                        pattern: suggestion.pattern,
                        description: suggestion.description,
                        isAdded: isPatternAdded(suggestion.pattern),
                        onAdd: { addSuggestedPattern(suggestion) }
                    )
                    
                    if index < suggestions.count - 1 {
                        Divider().padding(.leading, 70)
                    }
                }
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .grootAppear(delay: 0.4)
        }
    }
    
    private var infoCallout: some View {
        GrootCallout(
            title: "how patterns work",
            message: "Patterns use * as a wildcard to match any digits. For example, +1800* blocks all 1-800 numbers.",
            icon: "lightbulb.fill",
            color: .grootSun
        )
        .grootAppear(delay: 0.5)
    }
    
    // MARK: - Computed Properties
    
    private var availableSuggestions: [(pattern: String, description: String)] {
        BlockPattern.commonPatterns.filter { suggestion in
            !patterns.contains { $0.pattern == suggestion.pattern }
        }
    }
    
    private func isPatternAdded(_ pattern: String) -> Bool {
        patterns.contains { $0.pattern == pattern }
    }
    
    // MARK: - Actions
    
    private func togglePattern(_ pattern: BlockPattern) {
        do {
            try callBlockingService.togglePattern(pattern.pattern)
            GrootHaptics.selection()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to toggle pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
    
    private func deletePattern(_ pattern: BlockPattern) {
        do {
            try callBlockingService.removePattern(pattern.pattern)
            toastMessage = "Pattern removed"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to remove pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
    
    private func addSuggestedPattern(_ suggestion: (pattern: String, description: String)) {
        do {
            try callBlockingService.addPattern(suggestion.pattern, description: suggestion.description)
            toastMessage = "Pattern added!"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to add pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
}

// MARK: - Pattern Stat Card

struct PatternStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.grootBark)
            
            Text(label.lowercased())
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootStone)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.grootSnow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Suggested Pattern Row

struct SuggestedPatternRow: View {
    let pattern: String
    let description: String
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.grootSky.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.grootSky)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pattern)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.grootBark)
                
                Text(description.lowercased())
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            
            Spacer()
            
            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.grootShield)
            } else {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.grootSky)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Patterns Tab View (For Main Tab Bar)

struct PatternsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    @Query(sort: \BlockPattern.createdAt, order: .reverse)
    private var patterns: [BlockPattern]
    
    @AppStorage("hideSuggestedPatterns") private var hideSuggestedPatterns = false
    
    @State private var showAddSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    private var filteredPatterns: [BlockPattern] {
        if searchText.isEmpty {
            return patterns
        }
        return patterns.filter {
            $0.pattern.localizedCaseInsensitiveContains(searchText) ||
            $0.patternDescription.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var enabledCount: Int {
        patterns.filter { $0.isEnabled }.count
    }
    
    private var totalMatches: Int {
        patterns.reduce(0) { $0 + $1.matchCount }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if !patterns.isEmpty {
                        statsSection
                        searchSection
                    }
                    
                    if patterns.isEmpty {
                        GrootEmptyState.noPatterns {
                            showAddSheet = true
                        }
                        .grootAppear(delay: 0)
                    } else if filteredPatterns.isEmpty {
                        GrootEmptyState.searchNoResults(query: searchText)
                            .grootAppear(delay: 0)
                    } else {
                        patternsListSection
                    }
                    
                    if !hideSuggestedPatterns && !availableSuggestions.isEmpty {
                        suggestedPatternsSection
                    }
                    
                    if hideSuggestedPatterns && !availableSuggestions.isEmpty {
                        showSuggestionsButton
                    }
                    
                    infoCallout
                }
                .padding(20)
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("patterns")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.grootBark)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    GrootIconButton("plus", variant: .primary, size: .small) {
                        showAddSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPatternSheet()
                .presentationDetents([.medium, .large])
        }
        .grootToast(isPresented: $showToast, message: toastMessage)
    }
    
    // MARK: - View Components
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            PatternStatCard(
                icon: "number",
                value: "\(patterns.count)",
                label: "patterns",
                color: .grootViolet
            )
            
            PatternStatCard(
                icon: "checkmark.circle.fill",
                value: "\(enabledCount)",
                label: "active",
                color: .grootShield
            )
            
            PatternStatCard(
                icon: "phone.down.fill",
                value: "\(totalMatches)",
                label: "blocked",
                color: .grootFlame
            )
        }
        .grootAppear(delay: 0)
    }
    
    private var searchSection: some View {
        GrootSearchField("search patterns", text: $searchText)
            .grootAppear(delay: 0.1)
    }
    
    private var patternsListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GrootText("your patterns", style: .heading)
                Spacer()
                Text("\(filteredPatterns.count) pattern\(filteredPatterns.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.grootStone)
            }
            .grootAppear(delay: 0.1)
            
            VStack(spacing: 0) {
                ForEach(filteredPatterns) { pattern in
                    PatternRow(
                        pattern: pattern,
                        onToggle: { togglePattern(pattern) },
                        onDelete: { deletePattern(pattern) }
                    )
                    
                    if pattern.id != filteredPatterns.last?.id {
                        Divider().padding(.leading, 70)
                    }
                }
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .grootAppear(delay: 0.2)
        }
    }
    
    private var suggestedPatternsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GrootText("suggested patterns", style: .heading)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        hideSuggestedPatterns = true
                    }
                    GrootHaptics.selection()
                } label: {
                    Text("hide")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                }
            }
            .grootAppear(delay: 0.3)
            
            VStack(spacing: 0) {
                let suggestions = availableSuggestions
                ForEach(suggestions.indices, id: \.self) { index in
                    let suggestion = suggestions[index]
                    SuggestedPatternRow(
                        pattern: suggestion.pattern,
                        description: suggestion.description,
                        isAdded: isPatternAdded(suggestion.pattern),
                        onAdd: { addSuggestedPattern(suggestion) }
                    )
                    
                    if index < suggestions.count - 1 {
                        Divider().padding(.leading, 70)
                    }
                }
            }
            .background(Color.grootSnow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .grootAppear(delay: 0.4)
        }
    }
    
    private var showSuggestionsButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                hideSuggestedPatterns = false
            }
            GrootHaptics.selection()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text("show suggested patterns")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color.grootSky)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.grootSky.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .grootAppear(delay: 0.3)
    }
    
    private var infoCallout: some View {
        GrootCallout(
            title: "how patterns work",
            message: "Patterns use * as a wildcard to match any digits. For example, +1800* blocks all 1-800 numbers.",
            icon: "lightbulb.fill",
            color: .grootSun
        )
        .grootAppear(delay: 0.5)
    }
    
    // MARK: - Computed Properties
    
    private var availableSuggestions: [(pattern: String, description: String)] {
        BlockPattern.commonPatterns.filter { suggestion in
            !patterns.contains { $0.pattern == suggestion.pattern }
        }
    }
    
    private func isPatternAdded(_ pattern: String) -> Bool {
        patterns.contains { $0.pattern == pattern }
    }
    
    // MARK: - Actions
    
    private func togglePattern(_ pattern: BlockPattern) {
        do {
            try callBlockingService.togglePattern(pattern.pattern)
            GrootHaptics.selection()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to toggle pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
    
    private func deletePattern(_ pattern: BlockPattern) {
        do {
            try callBlockingService.removePattern(pattern.pattern)
            toastMessage = "Pattern removed"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to remove pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
    
    private func addSuggestedPattern(_ suggestion: (pattern: String, description: String)) {
        do {
            try callBlockingService.addPattern(suggestion.pattern, description: suggestion.description)
            toastMessage = "Pattern added!"
            showToast = true
            GrootHaptics.success()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = "Failed to add pattern"
            showToast = true
            GrootHaptics.error()
        }
    }
}

// MARK: - Preview

#Preview("PatternsView") {
    PatternsView()
        .modelContainer(for: BlockPattern.self, inMemory: true)
}

#Preview("PatternsTabView") {
    PatternsTabView()
        .modelContainer(for: BlockPattern.self, inMemory: true)
}
