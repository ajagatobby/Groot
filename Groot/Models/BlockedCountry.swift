//
//  BlockedCountry.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a country that has been blocked for incoming calls
@Model
final class BlockedCountry {
    /// The country calling code (e.g., "+91" for India, "+1" for US)
    @Attribute(.unique) var countryCode: String
    
    /// The country's display name
    var countryName: String
    
    /// The ISO 3166-1 alpha-2 code (e.g., "IN" for India, "US" for United States)
    var isoCode: String
    
    /// When this country was blocked
    var blockedAt: Date
    
    /// Number of calls blocked from this country
    var callsBlocked: Int
    
    init(
        countryCode: String,
        countryName: String,
        isoCode: String,
        blockedAt: Date = Date(),
        callsBlocked: Int = 0
    ) {
        self.countryCode = countryCode
        self.countryName = countryName
        self.isoCode = isoCode
        self.blockedAt = blockedAt
        self.callsBlocked = callsBlocked
    }
    
    /// Record that a call from this country was blocked
    func recordBlockedCall() {
        callsBlocked += 1
    }
}

// MARK: - Convenience Extensions

extension BlockedCountry {
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
    
    /// Returns the numeric prefix for CallKit matching
    /// e.g., "+91" becomes 91
    var numericPrefix: Int64? {
        let digitsOnly = countryCode.replacingOccurrences(of: "+", with: "")
            .filter { $0.isNumber }
        return Int64(digitsOnly)
    }
    
    /// Display string combining flag and name
    var displayName: String {
        "\(flag) \(countryName)"
    }
}
