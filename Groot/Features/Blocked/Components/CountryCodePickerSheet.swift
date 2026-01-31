//
//  CountryCodePickerSheet.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI

// MARK: - Country Code Picker Sheet

struct CountryCodePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedCountry: Country
    @State private var searchText = ""
    
    private let countryService = CountryDataService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchSection
                countryList
            }
            .background(Color.grootCloud)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("select country")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    GrootCloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack(spacing: 16) {
            GrootSearchField("search countries", text: $searchText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Country List
    
    private var countryList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                // Current region country at top (if not searching)
                if searchText.isEmpty, let currentCountry = countryService.currentRegionCountry {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("your region")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.grootStone)
                            .padding(.horizontal, 16)
                        
                        CountryCodeRow(
                            country: currentCountry,
                            isSelected: selectedCountry.id == currentCountry.id
                        ) {
                            selectCountry(currentCountry)
                        }
                        .background(Color.grootSnow)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                
                // All countries (grouped by region or flat when searching)
                if searchText.isEmpty {
                    groupedCountries
                } else {
                    searchResultsList
                }
            }
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    // MARK: - Grouped Countries
    
    private var groupedCountries: some View {
        ForEach(Country.Region.allCases, id: \.self) { region in
            let countries = countryService.countriesByRegion[region] ?? []
            
            if !countries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(region.rawValue.lowercased())
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootStone)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 0) {
                        ForEach(countries) { country in
                            CountryCodeRow(
                                country: country,
                                isSelected: selectedCountry.id == country.id
                            ) {
                                selectCountry(country)
                            }
                            
                            if country.id != countries.last?.id {
                                Divider()
                                    .padding(.leading, 62)
                            }
                        }
                    }
                    .background(Color.grootSnow)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            let results = countryService.search(searchText)
            
            if results.isEmpty {
                emptySearchState
            } else {
                Text("\(results.count) results")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.grootStone)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    ForEach(results) { country in
                        CountryCodeRow(
                            country: country,
                            isSelected: selectedCountry.id == country.id
                        ) {
                            selectCountry(country)
                        }
                        
                        if country.id != results.last?.id {
                            Divider()
                                .padding(.leading, 62)
                        }
                    }
                }
                .background(Color.grootSnow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Empty State
    
    private var emptySearchState: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 40))
                .foregroundStyle(Color.grootPebble)
            
            Text("no countries found")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.grootStone)
            
            Text("try searching by country name or code")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color.grootPebble)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Actions
    
    private func selectCountry(_ country: Country) {
        withAnimation(.grootSnappy) {
            selectedCountry = country
        }
        GrootHaptics.selection()
        dismiss()
    }
}

// MARK: - Country Code Row

private struct CountryCodeRow: View {
    let country: Country
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name.lowercased())
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.grootBark)
                    
                    Text(country.callingCode)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.grootSky)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.grootSuccess)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.grootSuccessBg : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedCountry = CountryDataService.shared.country(forISOCode: "US")!
    
    CountryCodePickerSheet(selectedCountry: $selectedCountry)
}
