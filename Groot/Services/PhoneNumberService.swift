//
//  PhoneNumberService.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation

/// Service for parsing, validating, and formatting phone numbers
/// Handles conversion to E.164 format required by CallKit
@Observable
final class PhoneNumberService {
    
    // MARK: - Singleton
    
    static let shared = PhoneNumberService()
    
    private init() {}
    
    // MARK: - Phone Number Parsing
    
    /// Parse a phone number string and convert to E.164 format
    /// - Parameters:
    ///   - number: The raw phone number string
    ///   - defaultCountryCode: Default country code to use if not specified (e.g., "+1")
    /// - Returns: The phone number in E.164 format, or nil if invalid
    func parseToE164(_ number: String, defaultCountryCode: String = "+1") -> String? {
        // Remove all non-numeric characters except + at the start
        var cleaned = number.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it starts with +
        let hasPlus = cleaned.hasPrefix("+")
        
        // Remove all non-numeric characters
        cleaned = cleaned.filter { $0.isNumber }
        
        guard !cleaned.isEmpty else { return nil }
        
        // Validate minimum length (at least 4 digits for valid number)
        guard cleaned.count >= 4 else { return nil }
        
        // If original had +, it's already international format
        if hasPlus {
            return "+\(cleaned)"
        }
        
        // Check for common US formats
        if cleaned.count == 10 {
            // Assume US number without country code
            return "+1\(cleaned)"
        }
        
        if cleaned.count == 11 && cleaned.hasPrefix("1") {
            // US number with country code but no +
            return "+\(cleaned)"
        }
        
        // For other lengths, add the default country code
        let countryCodeDigits = defaultCountryCode.filter { $0.isNumber }
        if cleaned.hasPrefix(countryCodeDigits) {
            return "+\(cleaned)"
        } else {
            return "+\(countryCodeDigits)\(cleaned)"
        }
    }
    
    /// Format a phone number for display
    /// - Parameter e164Number: Phone number in E.164 format
    /// - Returns: Formatted display string
    func formatForDisplay(_ e164Number: String) -> String {
        let digits = e164Number.filter { $0.isNumber }
        
        // US number formatting
        if digits.hasPrefix("1") && digits.count == 11 {
            let areaCode = digits.dropFirst().prefix(3)
            let exchange = digits.dropFirst(4).prefix(3)
            let subscriber = digits.dropFirst(7).prefix(4)
            return "+1 (\(areaCode)) \(exchange)-\(subscriber)"
        }
        
        // Generic international formatting
        if digits.count > 4 {
            // Split into country code and rest
            return e164Number
        }
        
        return e164Number
    }
    
    /// Extract the country code from an E.164 number
    /// - Parameter e164Number: Phone number in E.164 format
    /// - Returns: The country code (e.g., "+1", "+44") or nil
    func extractCountryCode(_ e164Number: String) -> String? {
        let digits = e164Number.filter { $0.isNumber }
        
        // Try to match known country codes (ordered by length, longest first)
        for country in CountryDataService.shared.allCountries {
            let codeDigits = country.callingCode.filter { $0.isNumber }
            if digits.hasPrefix(codeDigits) {
                return country.callingCode
            }
        }
        
        return nil
    }
    
    /// Validate if a string is a valid phone number
    /// - Parameter number: The phone number to validate
    /// - Returns: True if valid
    func isValidPhoneNumber(_ number: String) -> Bool {
        let cleaned = number.filter { $0.isNumber }
        // Phone numbers should be at least 4 digits and at most 15 digits (E.164 max)
        return cleaned.count >= 4 && cleaned.count <= 15
    }
    
    /// Convert E.164 to Int64 for CallKit
    /// - Parameter e164Number: Phone number in E.164 format
    /// - Returns: The numeric representation
    func toInt64(_ e164Number: String) -> Int64? {
        let digits = e164Number.filter { $0.isNumber }
        return Int64(digits)
    }
    
    // MARK: - Pattern Matching
    
    /// Check if a phone number matches a pattern
    /// - Parameters:
    ///   - number: The phone number to check
    ///   - pattern: The pattern (supports * as wildcard)
    /// - Returns: True if matches
    func matches(number: String, pattern: String) -> Bool {
        let normalizedNumber = number.filter { $0.isNumber }
        let normalizedPattern = pattern.filter { $0.isNumber || $0 == "*" }
        
        return matchPattern(number: normalizedNumber, pattern: normalizedPattern)
    }
    
    private func matchPattern(number: String, pattern: String) -> Bool {
        var nIndex = number.startIndex
        var pIndex = pattern.startIndex
        
        while pIndex < pattern.endIndex {
            let pChar = pattern[pIndex]
            
            if pChar == "*" {
                // Wildcard - try to match rest of pattern from each position
                let nextP = pattern.index(after: pIndex)
                if nextP == pattern.endIndex {
                    return true // * at end matches everything
                }
                
                while nIndex <= number.endIndex {
                    if matchPattern(
                        number: String(number[nIndex...]),
                        pattern: String(pattern[nextP...])
                    ) {
                        return true
                    }
                    if nIndex < number.endIndex {
                        nIndex = number.index(after: nIndex)
                    } else {
                        break
                    }
                }
                return false
            } else {
                // Must match exactly
                if nIndex >= number.endIndex || number[nIndex] != pChar {
                    return false
                }
                nIndex = number.index(after: nIndex)
            }
            
            pIndex = pattern.index(after: pIndex)
        }
        
        return nIndex == number.endIndex
    }
    
    /// Check if a number starts with a country code
    /// - Parameters:
    ///   - number: The phone number
    ///   - countryCode: The country code (e.g., "+91")
    /// - Returns: True if the number is from that country
    func isFromCountry(number: String, countryCode: String) -> Bool {
        let numberDigits = number.filter { $0.isNumber }
        let codeDigits = countryCode.filter { $0.isNumber }
        return numberDigits.hasPrefix(codeDigits)
    }
}
