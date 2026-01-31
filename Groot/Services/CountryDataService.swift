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
        case centralAmerica = "Central America"
        case southAmerica = "South America"
        case caribbean = "Caribbean"
        case europe = "Europe"
        case middleEast = "Middle East"
        case asia = "Asia"
        case africa = "Africa"
        case oceania = "Oceania"
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
    
    /// Total country count
    var countryCount: Int {
        countries.count
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
    
    // MARK: - Complete Country Database (All 195+ Countries)
    
    private let countries: [Country] = [
        
        // ══════════════════════════════════════════════════════════════════
        // NORTH AMERICA
        // ══════════════════════════════════════════════════════════════════
        Country(id: "US", name: "United States", isoCode: "US", callingCode: "+1", region: .northAmerica),
        Country(id: "CA", name: "Canada", isoCode: "CA", callingCode: "+1", region: .northAmerica),
        Country(id: "MX", name: "Mexico", isoCode: "MX", callingCode: "+52", region: .northAmerica),
        Country(id: "GL", name: "Greenland", isoCode: "GL", callingCode: "+299", region: .northAmerica),
        Country(id: "BM", name: "Bermuda", isoCode: "BM", callingCode: "+1441", region: .northAmerica),
        
        // ══════════════════════════════════════════════════════════════════
        // CENTRAL AMERICA
        // ══════════════════════════════════════════════════════════════════
        Country(id: "GT", name: "Guatemala", isoCode: "GT", callingCode: "+502", region: .centralAmerica),
        Country(id: "BZ", name: "Belize", isoCode: "BZ", callingCode: "+501", region: .centralAmerica),
        Country(id: "HN", name: "Honduras", isoCode: "HN", callingCode: "+504", region: .centralAmerica),
        Country(id: "SV", name: "El Salvador", isoCode: "SV", callingCode: "+503", region: .centralAmerica),
        Country(id: "NI", name: "Nicaragua", isoCode: "NI", callingCode: "+505", region: .centralAmerica),
        Country(id: "CR", name: "Costa Rica", isoCode: "CR", callingCode: "+506", region: .centralAmerica),
        Country(id: "PA", name: "Panama", isoCode: "PA", callingCode: "+507", region: .centralAmerica),
        
        // ══════════════════════════════════════════════════════════════════
        // SOUTH AMERICA
        // ══════════════════════════════════════════════════════════════════
        Country(id: "BR", name: "Brazil", isoCode: "BR", callingCode: "+55", region: .southAmerica),
        Country(id: "AR", name: "Argentina", isoCode: "AR", callingCode: "+54", region: .southAmerica),
        Country(id: "CO", name: "Colombia", isoCode: "CO", callingCode: "+57", region: .southAmerica),
        Country(id: "CL", name: "Chile", isoCode: "CL", callingCode: "+56", region: .southAmerica),
        Country(id: "PE", name: "Peru", isoCode: "PE", callingCode: "+51", region: .southAmerica),
        Country(id: "VE", name: "Venezuela", isoCode: "VE", callingCode: "+58", region: .southAmerica),
        Country(id: "EC", name: "Ecuador", isoCode: "EC", callingCode: "+593", region: .southAmerica),
        Country(id: "BO", name: "Bolivia", isoCode: "BO", callingCode: "+591", region: .southAmerica),
        Country(id: "PY", name: "Paraguay", isoCode: "PY", callingCode: "+595", region: .southAmerica),
        Country(id: "UY", name: "Uruguay", isoCode: "UY", callingCode: "+598", region: .southAmerica),
        Country(id: "GY", name: "Guyana", isoCode: "GY", callingCode: "+592", region: .southAmerica),
        Country(id: "SR", name: "Suriname", isoCode: "SR", callingCode: "+597", region: .southAmerica),
        Country(id: "GF", name: "French Guiana", isoCode: "GF", callingCode: "+594", region: .southAmerica),
        Country(id: "FK", name: "Falkland Islands", isoCode: "FK", callingCode: "+500", region: .southAmerica),
        
        // ══════════════════════════════════════════════════════════════════
        // CARIBBEAN
        // ══════════════════════════════════════════════════════════════════
        Country(id: "CU", name: "Cuba", isoCode: "CU", callingCode: "+53", region: .caribbean),
        Country(id: "JM", name: "Jamaica", isoCode: "JM", callingCode: "+1876", region: .caribbean),
        Country(id: "HT", name: "Haiti", isoCode: "HT", callingCode: "+509", region: .caribbean),
        Country(id: "DO", name: "Dominican Republic", isoCode: "DO", callingCode: "+1809", region: .caribbean),
        Country(id: "PR", name: "Puerto Rico", isoCode: "PR", callingCode: "+1787", region: .caribbean),
        Country(id: "TT", name: "Trinidad and Tobago", isoCode: "TT", callingCode: "+1868", region: .caribbean),
        Country(id: "BS", name: "Bahamas", isoCode: "BS", callingCode: "+1242", region: .caribbean),
        Country(id: "BB", name: "Barbados", isoCode: "BB", callingCode: "+1246", region: .caribbean),
        Country(id: "LC", name: "Saint Lucia", isoCode: "LC", callingCode: "+1758", region: .caribbean),
        Country(id: "GD", name: "Grenada", isoCode: "GD", callingCode: "+1473", region: .caribbean),
        Country(id: "VC", name: "Saint Vincent and the Grenadines", isoCode: "VC", callingCode: "+1784", region: .caribbean),
        Country(id: "AG", name: "Antigua and Barbuda", isoCode: "AG", callingCode: "+1268", region: .caribbean),
        Country(id: "DM", name: "Dominica", isoCode: "DM", callingCode: "+1767", region: .caribbean),
        Country(id: "KN", name: "Saint Kitts and Nevis", isoCode: "KN", callingCode: "+1869", region: .caribbean),
        Country(id: "AW", name: "Aruba", isoCode: "AW", callingCode: "+297", region: .caribbean),
        Country(id: "CW", name: "Curaçao", isoCode: "CW", callingCode: "+599", region: .caribbean),
        Country(id: "SX", name: "Sint Maarten", isoCode: "SX", callingCode: "+1721", region: .caribbean),
        Country(id: "BQ", name: "Bonaire", isoCode: "BQ", callingCode: "+599", region: .caribbean),
        Country(id: "VG", name: "British Virgin Islands", isoCode: "VG", callingCode: "+1284", region: .caribbean),
        Country(id: "VI", name: "U.S. Virgin Islands", isoCode: "VI", callingCode: "+1340", region: .caribbean),
        Country(id: "KY", name: "Cayman Islands", isoCode: "KY", callingCode: "+1345", region: .caribbean),
        Country(id: "TC", name: "Turks and Caicos Islands", isoCode: "TC", callingCode: "+1649", region: .caribbean),
        Country(id: "AI", name: "Anguilla", isoCode: "AI", callingCode: "+1264", region: .caribbean),
        Country(id: "MS", name: "Montserrat", isoCode: "MS", callingCode: "+1664", region: .caribbean),
        Country(id: "GP", name: "Guadeloupe", isoCode: "GP", callingCode: "+590", region: .caribbean),
        Country(id: "MQ", name: "Martinique", isoCode: "MQ", callingCode: "+596", region: .caribbean),
        Country(id: "BL", name: "Saint Barthélemy", isoCode: "BL", callingCode: "+590", region: .caribbean),
        Country(id: "MF", name: "Saint Martin", isoCode: "MF", callingCode: "+590", region: .caribbean),
        
        // ══════════════════════════════════════════════════════════════════
        // EUROPE
        // ══════════════════════════════════════════════════════════════════
        // Western Europe
        Country(id: "GB", name: "United Kingdom", isoCode: "GB", callingCode: "+44", region: .europe),
        Country(id: "DE", name: "Germany", isoCode: "DE", callingCode: "+49", region: .europe),
        Country(id: "FR", name: "France", isoCode: "FR", callingCode: "+33", region: .europe),
        Country(id: "IT", name: "Italy", isoCode: "IT", callingCode: "+39", region: .europe),
        Country(id: "ES", name: "Spain", isoCode: "ES", callingCode: "+34", region: .europe),
        Country(id: "PT", name: "Portugal", isoCode: "PT", callingCode: "+351", region: .europe),
        Country(id: "NL", name: "Netherlands", isoCode: "NL", callingCode: "+31", region: .europe),
        Country(id: "BE", name: "Belgium", isoCode: "BE", callingCode: "+32", region: .europe),
        Country(id: "LU", name: "Luxembourg", isoCode: "LU", callingCode: "+352", region: .europe),
        Country(id: "CH", name: "Switzerland", isoCode: "CH", callingCode: "+41", region: .europe),
        Country(id: "AT", name: "Austria", isoCode: "AT", callingCode: "+43", region: .europe),
        Country(id: "IE", name: "Ireland", isoCode: "IE", callingCode: "+353", region: .europe),
        Country(id: "MC", name: "Monaco", isoCode: "MC", callingCode: "+377", region: .europe),
        Country(id: "LI", name: "Liechtenstein", isoCode: "LI", callingCode: "+423", region: .europe),
        Country(id: "AD", name: "Andorra", isoCode: "AD", callingCode: "+376", region: .europe),
        Country(id: "SM", name: "San Marino", isoCode: "SM", callingCode: "+378", region: .europe),
        Country(id: "VA", name: "Vatican City", isoCode: "VA", callingCode: "+379", region: .europe),
        Country(id: "MT", name: "Malta", isoCode: "MT", callingCode: "+356", region: .europe),
        Country(id: "GI", name: "Gibraltar", isoCode: "GI", callingCode: "+350", region: .europe),
        
        // Northern Europe
        Country(id: "SE", name: "Sweden", isoCode: "SE", callingCode: "+46", region: .europe),
        Country(id: "NO", name: "Norway", isoCode: "NO", callingCode: "+47", region: .europe),
        Country(id: "DK", name: "Denmark", isoCode: "DK", callingCode: "+45", region: .europe),
        Country(id: "FI", name: "Finland", isoCode: "FI", callingCode: "+358", region: .europe),
        Country(id: "IS", name: "Iceland", isoCode: "IS", callingCode: "+354", region: .europe),
        Country(id: "FO", name: "Faroe Islands", isoCode: "FO", callingCode: "+298", region: .europe),
        Country(id: "AX", name: "Åland Islands", isoCode: "AX", callingCode: "+358", region: .europe),
        
        // Eastern Europe
        Country(id: "PL", name: "Poland", isoCode: "PL", callingCode: "+48", region: .europe),
        Country(id: "CZ", name: "Czech Republic", isoCode: "CZ", callingCode: "+420", region: .europe),
        Country(id: "SK", name: "Slovakia", isoCode: "SK", callingCode: "+421", region: .europe),
        Country(id: "HU", name: "Hungary", isoCode: "HU", callingCode: "+36", region: .europe),
        Country(id: "RO", name: "Romania", isoCode: "RO", callingCode: "+40", region: .europe),
        Country(id: "BG", name: "Bulgaria", isoCode: "BG", callingCode: "+359", region: .europe),
        Country(id: "UA", name: "Ukraine", isoCode: "UA", callingCode: "+380", region: .europe),
        Country(id: "BY", name: "Belarus", isoCode: "BY", callingCode: "+375", region: .europe),
        Country(id: "MD", name: "Moldova", isoCode: "MD", callingCode: "+373", region: .europe),
        Country(id: "RU", name: "Russia", isoCode: "RU", callingCode: "+7", region: .europe),
        
        // Baltic States
        Country(id: "EE", name: "Estonia", isoCode: "EE", callingCode: "+372", region: .europe),
        Country(id: "LV", name: "Latvia", isoCode: "LV", callingCode: "+371", region: .europe),
        Country(id: "LT", name: "Lithuania", isoCode: "LT", callingCode: "+370", region: .europe),
        
        // Balkans
        Country(id: "GR", name: "Greece", isoCode: "GR", callingCode: "+30", region: .europe),
        Country(id: "HR", name: "Croatia", isoCode: "HR", callingCode: "+385", region: .europe),
        Country(id: "SI", name: "Slovenia", isoCode: "SI", callingCode: "+386", region: .europe),
        Country(id: "BA", name: "Bosnia and Herzegovina", isoCode: "BA", callingCode: "+387", region: .europe),
        Country(id: "RS", name: "Serbia", isoCode: "RS", callingCode: "+381", region: .europe),
        Country(id: "ME", name: "Montenegro", isoCode: "ME", callingCode: "+382", region: .europe),
        Country(id: "MK", name: "North Macedonia", isoCode: "MK", callingCode: "+389", region: .europe),
        Country(id: "AL", name: "Albania", isoCode: "AL", callingCode: "+355", region: .europe),
        Country(id: "XK", name: "Kosovo", isoCode: "XK", callingCode: "+383", region: .europe),
        Country(id: "CY", name: "Cyprus", isoCode: "CY", callingCode: "+357", region: .europe),
        
        // Caucasus (European side)
        Country(id: "GE", name: "Georgia", isoCode: "GE", callingCode: "+995", region: .europe),
        Country(id: "AM", name: "Armenia", isoCode: "AM", callingCode: "+374", region: .europe),
        Country(id: "AZ", name: "Azerbaijan", isoCode: "AZ", callingCode: "+994", region: .europe),
        
        // ══════════════════════════════════════════════════════════════════
        // MIDDLE EAST
        // ══════════════════════════════════════════════════════════════════
        Country(id: "TR", name: "Turkey", isoCode: "TR", callingCode: "+90", region: .middleEast),
        Country(id: "SA", name: "Saudi Arabia", isoCode: "SA", callingCode: "+966", region: .middleEast),
        Country(id: "AE", name: "United Arab Emirates", isoCode: "AE", callingCode: "+971", region: .middleEast),
        Country(id: "IL", name: "Israel", isoCode: "IL", callingCode: "+972", region: .middleEast),
        Country(id: "PS", name: "Palestine", isoCode: "PS", callingCode: "+970", region: .middleEast),
        Country(id: "JO", name: "Jordan", isoCode: "JO", callingCode: "+962", region: .middleEast),
        Country(id: "LB", name: "Lebanon", isoCode: "LB", callingCode: "+961", region: .middleEast),
        Country(id: "SY", name: "Syria", isoCode: "SY", callingCode: "+963", region: .middleEast),
        Country(id: "IQ", name: "Iraq", isoCode: "IQ", callingCode: "+964", region: .middleEast),
        Country(id: "IR", name: "Iran", isoCode: "IR", callingCode: "+98", region: .middleEast),
        Country(id: "KW", name: "Kuwait", isoCode: "KW", callingCode: "+965", region: .middleEast),
        Country(id: "QA", name: "Qatar", isoCode: "QA", callingCode: "+974", region: .middleEast),
        Country(id: "BH", name: "Bahrain", isoCode: "BH", callingCode: "+973", region: .middleEast),
        Country(id: "OM", name: "Oman", isoCode: "OM", callingCode: "+968", region: .middleEast),
        Country(id: "YE", name: "Yemen", isoCode: "YE", callingCode: "+967", region: .middleEast),
        
        // ══════════════════════════════════════════════════════════════════
        // ASIA
        // ══════════════════════════════════════════════════════════════════
        // East Asia
        Country(id: "CN", name: "China", isoCode: "CN", callingCode: "+86", region: .asia),
        Country(id: "JP", name: "Japan", isoCode: "JP", callingCode: "+81", region: .asia),
        Country(id: "KR", name: "South Korea", isoCode: "KR", callingCode: "+82", region: .asia),
        Country(id: "KP", name: "North Korea", isoCode: "KP", callingCode: "+850", region: .asia),
        Country(id: "TW", name: "Taiwan", isoCode: "TW", callingCode: "+886", region: .asia),
        Country(id: "HK", name: "Hong Kong", isoCode: "HK", callingCode: "+852", region: .asia),
        Country(id: "MO", name: "Macau", isoCode: "MO", callingCode: "+853", region: .asia),
        Country(id: "MN", name: "Mongolia", isoCode: "MN", callingCode: "+976", region: .asia),
        
        // Southeast Asia
        Country(id: "TH", name: "Thailand", isoCode: "TH", callingCode: "+66", region: .asia),
        Country(id: "VN", name: "Vietnam", isoCode: "VN", callingCode: "+84", region: .asia),
        Country(id: "MY", name: "Malaysia", isoCode: "MY", callingCode: "+60", region: .asia),
        Country(id: "SG", name: "Singapore", isoCode: "SG", callingCode: "+65", region: .asia),
        Country(id: "ID", name: "Indonesia", isoCode: "ID", callingCode: "+62", region: .asia),
        Country(id: "PH", name: "Philippines", isoCode: "PH", callingCode: "+63", region: .asia),
        Country(id: "MM", name: "Myanmar", isoCode: "MM", callingCode: "+95", region: .asia),
        Country(id: "KH", name: "Cambodia", isoCode: "KH", callingCode: "+855", region: .asia),
        Country(id: "LA", name: "Laos", isoCode: "LA", callingCode: "+856", region: .asia),
        Country(id: "BN", name: "Brunei", isoCode: "BN", callingCode: "+673", region: .asia),
        Country(id: "TL", name: "Timor-Leste", isoCode: "TL", callingCode: "+670", region: .asia),
        
        // South Asia
        Country(id: "IN", name: "India", isoCode: "IN", callingCode: "+91", region: .asia),
        Country(id: "PK", name: "Pakistan", isoCode: "PK", callingCode: "+92", region: .asia),
        Country(id: "BD", name: "Bangladesh", isoCode: "BD", callingCode: "+880", region: .asia),
        Country(id: "NP", name: "Nepal", isoCode: "NP", callingCode: "+977", region: .asia),
        Country(id: "LK", name: "Sri Lanka", isoCode: "LK", callingCode: "+94", region: .asia),
        Country(id: "BT", name: "Bhutan", isoCode: "BT", callingCode: "+975", region: .asia),
        Country(id: "MV", name: "Maldives", isoCode: "MV", callingCode: "+960", region: .asia),
        Country(id: "AF", name: "Afghanistan", isoCode: "AF", callingCode: "+93", region: .asia),
        
        // Central Asia
        Country(id: "KZ", name: "Kazakhstan", isoCode: "KZ", callingCode: "+7", region: .asia),
        Country(id: "UZ", name: "Uzbekistan", isoCode: "UZ", callingCode: "+998", region: .asia),
        Country(id: "TM", name: "Turkmenistan", isoCode: "TM", callingCode: "+993", region: .asia),
        Country(id: "TJ", name: "Tajikistan", isoCode: "TJ", callingCode: "+992", region: .asia),
        Country(id: "KG", name: "Kyrgyzstan", isoCode: "KG", callingCode: "+996", region: .asia),
        
        // ══════════════════════════════════════════════════════════════════
        // AFRICA
        // ══════════════════════════════════════════════════════════════════
        // North Africa
        Country(id: "EG", name: "Egypt", isoCode: "EG", callingCode: "+20", region: .africa),
        Country(id: "LY", name: "Libya", isoCode: "LY", callingCode: "+218", region: .africa),
        Country(id: "TN", name: "Tunisia", isoCode: "TN", callingCode: "+216", region: .africa),
        Country(id: "DZ", name: "Algeria", isoCode: "DZ", callingCode: "+213", region: .africa),
        Country(id: "MA", name: "Morocco", isoCode: "MA", callingCode: "+212", region: .africa),
        Country(id: "SD", name: "Sudan", isoCode: "SD", callingCode: "+249", region: .africa),
        Country(id: "SS", name: "South Sudan", isoCode: "SS", callingCode: "+211", region: .africa),
        Country(id: "MR", name: "Mauritania", isoCode: "MR", callingCode: "+222", region: .africa),
        Country(id: "EH", name: "Western Sahara", isoCode: "EH", callingCode: "+212", region: .africa),
        
        // West Africa
        Country(id: "NG", name: "Nigeria", isoCode: "NG", callingCode: "+234", region: .africa),
        Country(id: "GH", name: "Ghana", isoCode: "GH", callingCode: "+233", region: .africa),
        Country(id: "CI", name: "Côte d'Ivoire", isoCode: "CI", callingCode: "+225", region: .africa),
        Country(id: "SN", name: "Senegal", isoCode: "SN", callingCode: "+221", region: .africa),
        Country(id: "ML", name: "Mali", isoCode: "ML", callingCode: "+223", region: .africa),
        Country(id: "BF", name: "Burkina Faso", isoCode: "BF", callingCode: "+226", region: .africa),
        Country(id: "NE", name: "Niger", isoCode: "NE", callingCode: "+227", region: .africa),
        Country(id: "GN", name: "Guinea", isoCode: "GN", callingCode: "+224", region: .africa),
        Country(id: "BJ", name: "Benin", isoCode: "BJ", callingCode: "+229", region: .africa),
        Country(id: "TG", name: "Togo", isoCode: "TG", callingCode: "+228", region: .africa),
        Country(id: "SL", name: "Sierra Leone", isoCode: "SL", callingCode: "+232", region: .africa),
        Country(id: "LR", name: "Liberia", isoCode: "LR", callingCode: "+231", region: .africa),
        Country(id: "GM", name: "Gambia", isoCode: "GM", callingCode: "+220", region: .africa),
        Country(id: "GW", name: "Guinea-Bissau", isoCode: "GW", callingCode: "+245", region: .africa),
        Country(id: "CV", name: "Cape Verde", isoCode: "CV", callingCode: "+238", region: .africa),
        
        // Central Africa
        Country(id: "CD", name: "DR Congo", isoCode: "CD", callingCode: "+243", region: .africa),
        Country(id: "CG", name: "Republic of the Congo", isoCode: "CG", callingCode: "+242", region: .africa),
        Country(id: "CM", name: "Cameroon", isoCode: "CM", callingCode: "+237", region: .africa),
        Country(id: "GA", name: "Gabon", isoCode: "GA", callingCode: "+241", region: .africa),
        Country(id: "GQ", name: "Equatorial Guinea", isoCode: "GQ", callingCode: "+240", region: .africa),
        Country(id: "CF", name: "Central African Republic", isoCode: "CF", callingCode: "+236", region: .africa),
        Country(id: "TD", name: "Chad", isoCode: "TD", callingCode: "+235", region: .africa),
        Country(id: "AO", name: "Angola", isoCode: "AO", callingCode: "+244", region: .africa),
        Country(id: "ST", name: "São Tomé and Príncipe", isoCode: "ST", callingCode: "+239", region: .africa),
        
        // East Africa
        Country(id: "KE", name: "Kenya", isoCode: "KE", callingCode: "+254", region: .africa),
        Country(id: "TZ", name: "Tanzania", isoCode: "TZ", callingCode: "+255", region: .africa),
        Country(id: "UG", name: "Uganda", isoCode: "UG", callingCode: "+256", region: .africa),
        Country(id: "RW", name: "Rwanda", isoCode: "RW", callingCode: "+250", region: .africa),
        Country(id: "BI", name: "Burundi", isoCode: "BI", callingCode: "+257", region: .africa),
        Country(id: "ET", name: "Ethiopia", isoCode: "ET", callingCode: "+251", region: .africa),
        Country(id: "ER", name: "Eritrea", isoCode: "ER", callingCode: "+291", region: .africa),
        Country(id: "DJ", name: "Djibouti", isoCode: "DJ", callingCode: "+253", region: .africa),
        Country(id: "SO", name: "Somalia", isoCode: "SO", callingCode: "+252", region: .africa),
        Country(id: "MG", name: "Madagascar", isoCode: "MG", callingCode: "+261", region: .africa),
        Country(id: "MW", name: "Malawi", isoCode: "MW", callingCode: "+265", region: .africa),
        Country(id: "ZM", name: "Zambia", isoCode: "ZM", callingCode: "+260", region: .africa),
        Country(id: "ZW", name: "Zimbabwe", isoCode: "ZW", callingCode: "+263", region: .africa),
        Country(id: "MZ", name: "Mozambique", isoCode: "MZ", callingCode: "+258", region: .africa),
        
        // Southern Africa
        Country(id: "ZA", name: "South Africa", isoCode: "ZA", callingCode: "+27", region: .africa),
        Country(id: "NA", name: "Namibia", isoCode: "NA", callingCode: "+264", region: .africa),
        Country(id: "BW", name: "Botswana", isoCode: "BW", callingCode: "+267", region: .africa),
        Country(id: "SZ", name: "Eswatini", isoCode: "SZ", callingCode: "+268", region: .africa),
        Country(id: "LS", name: "Lesotho", isoCode: "LS", callingCode: "+266", region: .africa),
        
        // Island Nations
        Country(id: "MU", name: "Mauritius", isoCode: "MU", callingCode: "+230", region: .africa),
        Country(id: "SC", name: "Seychelles", isoCode: "SC", callingCode: "+248", region: .africa),
        Country(id: "KM", name: "Comoros", isoCode: "KM", callingCode: "+269", region: .africa),
        Country(id: "RE", name: "Réunion", isoCode: "RE", callingCode: "+262", region: .africa),
        Country(id: "YT", name: "Mayotte", isoCode: "YT", callingCode: "+262", region: .africa),
        
        // ══════════════════════════════════════════════════════════════════
        // OCEANIA
        // ══════════════════════════════════════════════════════════════════
        // Australia & New Zealand
        Country(id: "AU", name: "Australia", isoCode: "AU", callingCode: "+61", region: .oceania),
        Country(id: "NZ", name: "New Zealand", isoCode: "NZ", callingCode: "+64", region: .oceania),
        
        // Melanesia
        Country(id: "PG", name: "Papua New Guinea", isoCode: "PG", callingCode: "+675", region: .oceania),
        Country(id: "FJ", name: "Fiji", isoCode: "FJ", callingCode: "+679", region: .oceania),
        Country(id: "SB", name: "Solomon Islands", isoCode: "SB", callingCode: "+677", region: .oceania),
        Country(id: "VU", name: "Vanuatu", isoCode: "VU", callingCode: "+678", region: .oceania),
        Country(id: "NC", name: "New Caledonia", isoCode: "NC", callingCode: "+687", region: .oceania),
        
        // Micronesia
        Country(id: "GU", name: "Guam", isoCode: "GU", callingCode: "+1671", region: .oceania),
        Country(id: "PW", name: "Palau", isoCode: "PW", callingCode: "+680", region: .oceania),
        Country(id: "FM", name: "Micronesia", isoCode: "FM", callingCode: "+691", region: .oceania),
        Country(id: "MH", name: "Marshall Islands", isoCode: "MH", callingCode: "+692", region: .oceania),
        Country(id: "KI", name: "Kiribati", isoCode: "KI", callingCode: "+686", region: .oceania),
        Country(id: "NR", name: "Nauru", isoCode: "NR", callingCode: "+674", region: .oceania),
        Country(id: "MP", name: "Northern Mariana Islands", isoCode: "MP", callingCode: "+1670", region: .oceania),
        
        // Polynesia
        Country(id: "WS", name: "Samoa", isoCode: "WS", callingCode: "+685", region: .oceania),
        Country(id: "AS", name: "American Samoa", isoCode: "AS", callingCode: "+1684", region: .oceania),
        Country(id: "TO", name: "Tonga", isoCode: "TO", callingCode: "+676", region: .oceania),
        Country(id: "TV", name: "Tuvalu", isoCode: "TV", callingCode: "+688", region: .oceania),
        Country(id: "PF", name: "French Polynesia", isoCode: "PF", callingCode: "+689", region: .oceania),
        Country(id: "CK", name: "Cook Islands", isoCode: "CK", callingCode: "+682", region: .oceania),
        Country(id: "NU", name: "Niue", isoCode: "NU", callingCode: "+683", region: .oceania),
        Country(id: "TK", name: "Tokelau", isoCode: "TK", callingCode: "+690", region: .oceania),
        Country(id: "WF", name: "Wallis and Futuna", isoCode: "WF", callingCode: "+681", region: .oceania),
        Country(id: "PN", name: "Pitcairn Islands", isoCode: "PN", callingCode: "+64", region: .oceania),
        Country(id: "NF", name: "Norfolk Island", isoCode: "NF", callingCode: "+672", region: .oceania),
        Country(id: "CX", name: "Christmas Island", isoCode: "CX", callingCode: "+61", region: .oceania),
        Country(id: "CC", name: "Cocos Islands", isoCode: "CC", callingCode: "+61", region: .oceania),
    ]
}
