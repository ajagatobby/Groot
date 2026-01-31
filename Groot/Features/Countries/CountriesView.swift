//
//  CountriesView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData
import UIKit

// MARK: - Countries View

struct CountriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.callBlockingService) private var callBlockingService
    
    @Query(sort: \BlockedCountry.blockedAt, order: .reverse)
    private var blockedCountries: [BlockedCountry]
    
    @State private var searchText = ""
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // MARK: - Computed Properties
    
    private var filteredCountriesByRegion: [Country.Region: [Country]] {
        let countries = searchText.isEmpty
            ? CountryDataService.shared.allCountries
            : CountryDataService.shared.search(searchText)
        return Dictionary(grouping: countries) { $0.region }
    }
    
    private var blockedCountryCodes: Set<String> {
        Set(blockedCountries.map { $0.countryCode })
    }
    
    private func blockedCountry(for code: String) -> BlockedCountry? {
        blockedCountries.first { $0.countryCode == code }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CountrySearchHeader(
                        searchText: $searchText,
                        blockedCount: blockedCountries.count
                    )
                    .grootAppear(delay: 0)
                    
                    if !blockedCountries.isEmpty {
                        blockedCountriesSection
                    }
                    
                    countriesByRegionSection
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("countries")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
            }
        }
        .grootToast(isPresented: $showToast, message: toastMessage)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var blockedCountriesSection: some View {
        HStack {
            GrootText("blocked countries", style: .heading)
            Spacer()
        }
        .grootAppear(delay: 0.1)
        
        VStack(spacing: 12) {
            ForEach(blockedCountries) { blocked in
                BlockedCountryCard(
                    flag: blocked.flag,
                    name: blocked.countryName,
                    code: blocked.countryCode,
                    blockedCalls: blocked.callsBlocked,
                    blockedSince: blocked.blockedAt,
                    onUnblock: { unblockCountry(blocked) }
                )
            }
        }
        .grootAppear(delay: 0.2)
    }
    
    @ViewBuilder
    private var countriesByRegionSection: some View {
        ForEach(Country.Region.allCases, id: \.self) { region in
            if let countries = filteredCountriesByRegion[region], !countries.isEmpty {
                CountryRegionSection(
                    region: region.rawValue,
                    countries: countries.map { country in
                        let blocked = blockedCountry(for: country.callingCode)
                        return CountryRegionSection.CountryItem(
                            flag: country.flag,
                            name: country.name,
                            code: country.callingCode,
                            isBlocked: blockedCountryCodes.contains(country.callingCode),
                            blockedCalls: blocked?.callsBlocked ?? 0
                        )
                    },
                    onToggle: { item in
                        toggleCountryBlocking(item, country: countries.first { $0.callingCode == item.code })
                    }
                )
                .grootAppear(delay: 0.3)
            }
        }
    }
    
    // MARK: - Actions
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func toggleCountryBlocking(_ item: CountryRegionSection.CountryItem, country: Country?) {
        guard let country = country else { return }
        
        if item.isBlocked {
            unblockCountryCode(item.code)
        } else {
            blockCountry(country)
        }
    }
    
    private func blockCountry(_ country: Country) {
        dismissKeyboard()
        
        do {
            try callBlockingService.blockCountry(country)
            toastMessage = "\(country.flag) \(country.name) blocked"
            showToast = true
            GrootHaptics.blockConfirmed()
            
            Task {
                try? await callBlockingService.reloadCallDirectory()
            }
        } catch {
            toastMessage = error.localizedDescription
            showToast = true
            GrootHaptics.error()
        }
    }
    
    private func unblockCountry(_ blocked: BlockedCountry) {
        unblockCountryCode(blocked.countryCode)
    }
    
    private func unblockCountryCode(_ code: String) {
        do {
            try callBlockingService.unblockCountry(code)
            toastMessage = "Country unblocked"
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
    CountriesView()
        .modelContainer(for: BlockedCountry.self, inMemory: true)
}
