//
//  CountriesView.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

// MARK: - Countries View

struct CountriesView: View {
    
    // MARK: - Environment
    
    @Environment(\.callBlockingService) private var callBlockingService
    
    // MARK: - Data
    
    @Query(sort: \BlockedCountry.blockedAt, order: .reverse)
    private var blockedCountries: [BlockedCountry]
    
    // MARK: - ViewModel
    
    @State private var viewModel: CountriesViewModel?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    CountrySearchHeader(
                        searchText: Binding(
                            get: { viewModel?.searchText ?? "" },
                            set: { viewModel?.searchText = $0 }
                        ),
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
        .grootToast(
            isPresented: Binding(
                get: { viewModel?.showToast ?? false },
                set: { viewModel?.showToast = $0 }
            ),
            message: viewModel?.toastMessage ?? ""
        )
        .onAppear {
            if viewModel == nil {
                viewModel = CountriesViewModel(callBlockingService: callBlockingService)
            }
        }
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
                    onUnblock: { viewModel?.unblockCountry(blocked) }
                )
            }
        }
        .grootAppear(delay: 0.2)
    }
    
    @ViewBuilder
    private var countriesByRegionSection: some View {
        let filteredByRegion = viewModel?.filteredCountriesByRegion ?? [:]
        
        ForEach(Country.Region.allCases, id: \.self) { region in
            if let countries = filteredByRegion[region], !countries.isEmpty {
                CountryRegionSection(
                    region: region.rawValue,
                    countries: viewModel?.mapToCountryItems(
                        countries: countries,
                        blockedCountries: blockedCountries
                    ) ?? [],
                    onToggle: { item in
                        viewModel?.toggleCountryBlocking(item, from: countries)
                    }
                )
                .grootAppear(delay: 0.3)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CountriesView()
        .modelContainer(for: BlockedCountry.self, inMemory: true)
}
