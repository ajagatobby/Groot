//
//  CountryDataService.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation

/// Represents a country with its calling code and metadata
struct Country: Identifiable, Hashable {
    let id: String  // ISO code
    let name: String
    let isoCode: String
    let callingCode: String
    let region: Region
    
    /// Returns the flag emoji for this country
    var flag: String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in isoCode.uppercased().unicodeScalars {
            if let unicode = UnicodeScalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag.isEmpty ? "🏳️" : flag
    }
    
    /// Display string with flag and name
    var displayName: String {
        "\(flag) \(name)"
    }
    
    /// Display string with code
    var displayWithCode: String {
        "\(flag) \(name) (\(callingCode))"
    }
    
    enum Region: String, CaseIterable {
        case northAmerica = "North America"
        case southAmerica = "South America"
        case europe = "Europe"
        case asia = "Asia"
        case africa = "Africa"
        case oceania = "Oceania"
        case caribbean = "Caribbean"
        case middleEast = "Middle East"
    }
}

/// Service providing country data for call blocking
@Observable
final class CountryDataService {
    
    // MARK: - Singleton
    
    static let shared = CountryDataService()
    
    private init() {}
    
    // MARK: - Data
    
    /// All countries sorted by name
    var allCountries: [Country] {
        countries.sorted { $0.name < $1.name }
    }
    
    /// Countries grouped by region
    var countriesByRegion: [Country.Region: [Country]] {
        Dictionary(grouping: countries) { $0.region }
            .mapValues { $0.sorted { $0.name < $1.name } }
    }
    
    /// Search countries by name or code
    func search(_ query: String) -> [Country] {
        guard !query.isEmpty else { return allCountries }
        
        let lowercased = query.lowercased()
        return countries.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.isoCode.lowercased().contains(lowercased) ||
            $0.callingCode.contains(query)
        }.sorted { $0.name < $1.name }
    }
    
    /// Find country by ISO code
    func country(forISOCode isoCode: String) -> Country? {
        countries.first { $0.isoCode.uppercased() == isoCode.uppercased() }
    }
    
    /// Find country by calling code
    func country(forCallingCode code: String) -> Country? {
        let digits = code.filter { $0.isNumber }
        return countries.first {
            $0.callingCode.filter { $0.isNumber } == digits
        }
    }
    
    /// Get the user's current region country (based on locale)
    var currentRegionCountry: Country? {
        if let regionCode = Locale.current.region?.identifier {
            return country(forISOCode: regionCode)
        }
        return nil
    }
    
    // MARK: - Country Database
    
    private let countries: [Country] = [
        // North America
        Country(id: "US", name: "United States", isoCode: "US", callingCode: "+1", region: .northAmerica),
        Country(id: "CA", name: "Canada", isoCode: "CA", callingCode: "+1", region: .northAmerica),
        Country(id: "MX", name: "Mexico", isoCode: "MX", callingCode: "+52", region: .northAmerica),
        
        // South America
        Country(id: "BR", name: "Brazil", isoCode: "BR", callingCode: "+55", region: .southAmerica),
        Country(id: "AR", name: "Argentina", isoCode: "AR", callingCode: "+54", region: .southAmerica),
        Country(id: "CO", name: "Colombia", isoCode: "CO", callingCode: "+57", region: .southAmerica),
        Country(id: "CL", name: "Chile", isoCode: "CL", callingCode: "+56", region: .southAmerica),
        Country(id: "PE", name: "Peru", isoCode: "PE", callingCode: "+51", region: .southAmerica),
        Country(id: "VE", name: "Venezuela", isoCode: "VE", callingCode: "+58", region: .southAmerica),
        Country(id: "EC", name: "Ecuador", isoCode: "EC", callingCode: "+593", region: .southAmerica),
        
        // Europe
        Country(id: "GB", name: "United Kingdom", isoCode: "GB", callingCode: "+44", region: .europe),
        Country(id: "DE", name: "Germany", isoCode: "DE", callingCode: "+49", region: .europe),
        Country(id: "FR", name: "France", isoCode: "FR", callingCode: "+33", region: .europe),
        Country(id: "IT", name: "Italy", isoCode: "IT", callingCode: "+39", region: .europe),
        Country(id: "ES", name: "Spain", isoCode: "ES", callingCode: "+34", region: .europe),
        Country(id: "NL", name: "Netherlands", isoCode: "NL", callingCode: "+31", region: .europe),
        Country(id: "BE", name: "Belgium", isoCode: "BE", callingCode: "+32", region: .europe),
        Country(id: "CH", name: "Switzerland", isoCode: "CH", callingCode: "+41", region: .europe),
        Country(id: "AT", name: "Austria", isoCode: "AT", callingCode: "+43", region: .europe),
        Country(id: "SE", name: "Sweden", isoCode: "SE", callingCode: "+46", region: .europe),
        Country(id: "NO", name: "Norway", isoCode: "NO", callingCode: "+47", region: .europe),
        Country(id: "DK", name: "Denmark", isoCode: "DK", callingCode: "+45", region: .europe),
        Country(id: "FI", name: "Finland", isoCode: "FI", callingCode: "+358", region: .europe),
        Country(id: "PL", name: "Poland", isoCode: "PL", callingCode: "+48", region: .europe),
        Country(id: "PT", name: "Portugal", isoCode: "PT", callingCode: "+351", region: .europe),
        Country(id: "IE", name: "Ireland", isoCode: "IE", callingCode: "+353", region: .europe),
        Country(id: "GR", name: "Greece", isoCode: "GR", callingCode: "+30", region: .europe),
        Country(id: "CZ", name: "Czech Republic", isoCode: "CZ", callingCode: "+420", region: .europe),
        Country(id: "RO", name: "Romania", isoCode: "RO", callingCode: "+40", region: .europe),
        Country(id: "HU", name: "Hungary", isoCode: "HU", callingCode: "+36", region: .europe),
        Country(id: "UA", name: "Ukraine", isoCode: "UA", callingCode: "+380", region: .europe),
        Country(id: "RU", name: "Russia", isoCode: "RU", callingCode: "+7", region: .europe),
        
        // Asia
        Country(id: "CN", name: "China", isoCode: "CN", callingCode: "+86", region: .asia),
        Country(id: "JP", name: "Japan", isoCode: "JP", callingCode: "+81", region: .asia),
        Country(id: "KR", name: "South Korea", isoCode: "KR", callingCode: "+82", region: .asia),
        Country(id: "IN", name: "India", isoCode: "IN", callingCode: "+91", region: .asia),
        Country(id: "ID", name: "Indonesia", isoCode: "ID", callingCode: "+62", region: .asia),
        Country(id: "TH", name: "Thailand", isoCode: "TH", callingCode: "+66", region: .asia),
        Country(id: "VN", name: "Vietnam", isoCode: "VN", callingCode: "+84", region: .asia),
        Country(id: "PH", name: "Philippines", isoCode: "PH", callingCode: "+63", region: .asia),
        Country(id: "MY", name: "Malaysia", isoCode: "MY", callingCode: "+60", region: .asia),
        Country(id: "SG", name: "Singapore", isoCode: "SG", callingCode: "+65", region: .asia),
        Country(id: "HK", name: "Hong Kong", isoCode: "HK", callingCode: "+852", region: .asia),
        Country(id: "TW", name: "Taiwan", isoCode: "TW", callingCode: "+886", region: .asia),
        Country(id: "PK", name: "Pakistan", isoCode: "PK", callingCode: "+92", region: .asia),
        Country(id: "BD", name: "Bangladesh", isoCode: "BD", callingCode: "+880", region: .asia),
        Country(id: "NP", name: "Nepal", isoCode: "NP", callingCode: "+977", region: .asia),
        Country(id: "LK", name: "Sri Lanka", isoCode: "LK", callingCode: "+94", region: .asia),
        Country(id: "MM", name: "Myanmar", isoCode: "MM", callingCode: "+95", region: .asia),
        
        // Middle East
        Country(id: "AE", name: "United Arab Emirates", isoCode: "AE", callingCode: "+971", region: .middleEast),
        Country(id: "SA", name: "Saudi Arabia", isoCode: "SA", callingCode: "+966", region: .middleEast),
        Country(id: "IL", name: "Israel", isoCode: "IL", callingCode: "+972", region: .middleEast),
        Country(id: "TR", name: "Turkey", isoCode: "TR", callingCode: "+90", region: .middleEast),
        Country(id: "IR", name: "Iran", isoCode: "IR", callingCode: "+98", region: .middleEast),
        Country(id: "IQ", name: "Iraq", isoCode: "IQ", callingCode: "+964", region: .middleEast),
        Country(id: "KW", name: "Kuwait", isoCode: "KW", callingCode: "+965", region: .middleEast),
        Country(id: "QA", name: "Qatar", isoCode: "QA", callingCode: "+974", region: .middleEast),
        Country(id: "BH", name: "Bahrain", isoCode: "BH", callingCode: "+973", region: .middleEast),
        Country(id: "OM", name: "Oman", isoCode: "OM", callingCode: "+968", region: .middleEast),
        Country(id: "JO", name: "Jordan", isoCode: "JO", callingCode: "+962", region: .middleEast),
        Country(id: "LB", name: "Lebanon", isoCode: "LB", callingCode: "+961", region: .middleEast),
        
        // Africa
        Country(id: "ZA", name: "South Africa", isoCode: "ZA", callingCode: "+27", region: .africa),
        Country(id: "NG", name: "Nigeria", isoCode: "NG", callingCode: "+234", region: .africa),
        Country(id: "EG", name: "Egypt", isoCode: "EG", callingCode: "+20", region: .africa),
        Country(id: "KE", name: "Kenya", isoCode: "KE", callingCode: "+254", region: .africa),
        Country(id: "GH", name: "Ghana", isoCode: "GH", callingCode: "+233", region: .africa),
        Country(id: "MA", name: "Morocco", isoCode: "MA", callingCode: "+212", region: .africa),
        Country(id: "TN", name: "Tunisia", isoCode: "TN", callingCode: "+216", region: .africa),
        Country(id: "DZ", name: "Algeria", isoCode: "DZ", callingCode: "+213", region: .africa),
        Country(id: "ET", name: "Ethiopia", isoCode: "ET", callingCode: "+251", region: .africa),
        Country(id: "TZ", name: "Tanzania", isoCode: "TZ", callingCode: "+255", region: .africa),
        Country(id: "UG", name: "Uganda", isoCode: "UG", callingCode: "+256", region: .africa),
        Country(id: "SN", name: "Senegal", isoCode: "SN", callingCode: "+221", region: .africa),
        
        // Oceania
        Country(id: "AU", name: "Australia", isoCode: "AU", callingCode: "+61", region: .oceania),
        Country(id: "NZ", name: "New Zealand", isoCode: "NZ", callingCode: "+64", region: .oceania),
        Country(id: "FJ", name: "Fiji", isoCode: "FJ", callingCode: "+679", region: .oceania),
        Country(id: "PG", name: "Papua New Guinea", isoCode: "PG", callingCode: "+675", region: .oceania),
        
        // Caribbean
        Country(id: "JM", name: "Jamaica", isoCode: "JM", callingCode: "+1876", region: .caribbean),
        Country(id: "TT", name: "Trinidad and Tobago", isoCode: "TT", callingCode: "+1868", region: .caribbean),
        Country(id: "BB", name: "Barbados", isoCode: "BB", callingCode: "+1246", region: .caribbean),
        Country(id: "BS", name: "Bahamas", isoCode: "BS", callingCode: "+1242", region: .caribbean),
        Country(id: "PR", name: "Puerto Rico", isoCode: "PR", callingCode: "+1787", region: .caribbean),
        Country(id: "DO", name: "Dominican Republic", isoCode: "DO", callingCode: "+1809", region: .caribbean),
        Country(id: "CU", name: "Cuba", isoCode: "CU", callingCode: "+53", region: .caribbean),
        Country(id: "HT", name: "Haiti", isoCode: "HT", callingCode: "+509", region: .caribbean),
    ]
}
