//
//  CountriesViewModel.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData
import Observation
import UIKit

// MARK: - Countries ViewModel

@MainActor
@Observable
final class CountriesViewModel {
    
    // MARK: - Dependencies
    
    private let callBlockingService: CallBlockingService
    private let countryService = CountryDataService.shared
    
    // MARK: - UI State
    
    var searchText = ""
    var showToast = false
    var toastMessage = ""
    
    // MARK: - Initialization
    
    init(callBlockingService: CallBlockingService) {
        self.callBlockingService = callBlockingService
    }
    
    // MARK: - Computed Properties
    
    var filteredCountriesByRegion: [Country.Region: [Country]] {
        let countries = searchText.isEmpty
            ? countryService.allCountries
            : countryService.search(searchText)
        return Dictionary(grouping: countries) { $0.region }
    }
    
    func blockedCountryCodes(from blockedCountries: [BlockedCountry]) -> Set<String> {
        Set(blockedCountries.map { $0.countryCode })
    }
    
    func blockedCountry(for code: String, from blockedCountries: [BlockedCountry]) -> BlockedCountry? {
        blockedCountries.first { $0.countryCode == code }
    }
    
    func mapToCountryItems(
        countries: [Country],
        blockedCountries: [BlockedCountry]
    ) -> [CountryRegionSection.CountryItem] {
        let blockedCodes = blockedCountryCodes(from: blockedCountries)
        return countries.map { country in
            let blocked = blockedCountry(for: country.callingCode, from: blockedCountries)
            return CountryRegionSection.CountryItem(
                flag: country.flag,
                name: country.name,
                code: country.callingCode,
                isBlocked: blockedCodes.contains(country.callingCode),
                blockedCalls: blocked?.callsBlocked ?? 0
            )
        }
    }
    
    // MARK: - Actions
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func toggleCountryBlocking(_ item: CountryRegionSection.CountryItem, from countries: [Country]) {
        guard let country = countries.first(where: { $0.callingCode == item.code }) else { return }
        
        if item.isBlocked {
            unblockCountryCode(item.code)
        } else {
            blockCountry(country)
        }
    }
    
    func blockCountry(_ country: Country) {
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
    
    func unblockCountry(_ blocked: BlockedCountry) {
        unblockCountryCode(blocked.countryCode)
    }
    
    func unblockCountryCode(_ code: String) {
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
