//
//  BlockPattern.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a pattern for blocking phone numbers
/// Patterns use wildcards to match multiple numbers
@Model
final class BlockPattern {
    /// The pattern string (e.g., "+1800*" to block all 1-800 numbers)
    /// Supports * as wildcard for any digits
    @Attribute(.unique) var pattern: String
    
    /// Human-readable description of what this pattern blocks
    var patternDescription: String
    
    /// When this pattern was created
    var createdAt: Date
    
    /// Number of calls this pattern has matched and blocked
    var matchCount: Int
    
    /// Whether this pattern is currently active
    var isEnabled: Bool
    
    init(
        pattern: String,
        description: String,
        createdAt: Date = Date(),
        matchCount: Int = 0,
        isEnabled: Bool = true
    ) {
        self.pattern = pattern
        self.patternDescription = description
        self.createdAt = createdAt
        self.matchCount = matchCount
        self.isEnabled = isEnabled
    }
    
    /// Record that this pattern matched a call
    func recordMatch() {
        matchCount += 1
    }
}

// MARK: - Pattern Matching

extension BlockPattern {
    /// Check if a phone number matches this pattern
    /// - Parameter phoneNumber: The phone number to check (should be in E.164 format)
    /// - Returns: True if the number matches the pattern
    func matches(_ phoneNumber: String) -> Bool {
        guard isEnabled else { return false }
        
        // Normalize the phone number
        let normalizedNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
            .filter { $0.isNumber }
        
        // Normalize the pattern
        let normalizedPattern = pattern.replacingOccurrences(of: "+", with: "")
            .filter { $0.isNumber || $0 == "*" }
        
        return matchesPattern(number: normalizedNumber, pattern: normalizedPattern)
    }
    
    /// Internal pattern matching logic
    private func matchesPattern(number: String, pattern: String) -> Bool {
        var numberIndex = number.startIndex
        var patternIndex = pattern.startIndex
        
        while patternIndex < pattern.endIndex {
            let patternChar = pattern[patternIndex]
            
            if patternChar == "*" {
                // Wildcard matches any remaining characters
                // Check if this is the last character in the pattern
                let nextPatternIndex = pattern.index(after: patternIndex)
                if nextPatternIndex == pattern.endIndex {
                    return true // * at end matches everything
                }
                
                // Try to match the rest of the pattern from each position
                while numberIndex <= number.endIndex {
                    if matchesPattern(
                        number: String(number[numberIndex...]),
                        pattern: String(pattern[nextPatternIndex...])
                    ) {
                        return true
                    }
                    if numberIndex < number.endIndex {
                        numberIndex = number.index(after: numberIndex)
                    } else {
                        break
                    }
                }
                return false
            } else {
                // Must match exactly
                if numberIndex >= number.endIndex || number[numberIndex] != patternChar {
                    return false
                }
                numberIndex = number.index(after: numberIndex)
            }
            
            patternIndex = pattern.index(after: patternIndex)
        }
        
        // Pattern exhausted, number should also be exhausted
        return numberIndex == number.endIndex
    }
}

// MARK: - Predefined Patterns

extension BlockPattern {
    /// Common patterns that users might want to use
    static let commonPatterns: [(pattern: String, description: String)] = [
        ("+1800*", "Toll-free 1-800 numbers"),
        ("+1888*", "Toll-free 1-888 numbers"),
        ("+1877*", "Toll-free 1-877 numbers"),
        ("+1866*", "Toll-free 1-866 numbers"),
        ("+1855*", "Toll-free 1-855 numbers"),
        ("+1844*", "Toll-free 1-844 numbers"),
        ("+1900*", "Premium rate 1-900 numbers"),
    ]
}
