//
//  BlockedNumber.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a blocked phone number in the call blocking system
@Model
final class BlockedNumber {
    /// The phone number in E.164 format (e.g., "+14155551234")
    /// This is the normalized format required by CallKit
    @Attribute(.unique) var phoneNumber: String
    
    /// The original number as entered by the user
    var rawNumber: String
    
    /// The reason this number was blocked
    var reasonRawValue: String
    
    /// Optional label for the blocked number (e.g., "Telemarketer", "Scam")
    var label: String?
    
    /// When this number was blocked
    var blockedAt: Date
    
    /// Number of times this number has tried to call since being blocked
    var callCount: Int
    
    /// The last time this number attempted to call
    var lastCallAt: Date?
    
    /// Computed property to get the BlockReason enum
    var reason: BlockReason {
        get { BlockReason(rawValue: reasonRawValue) ?? .manual }
        set { reasonRawValue = newValue.rawValue }
    }
    
    init(
        phoneNumber: String,
        rawNumber: String? = nil,
        reason: BlockReason = .manual,
        label: String? = nil,
        blockedAt: Date = Date(),
        callCount: Int = 0,
        lastCallAt: Date? = nil
    ) {
        self.phoneNumber = phoneNumber
        self.rawNumber = rawNumber ?? phoneNumber
        self.reasonRawValue = reason.rawValue
        self.label = label
        self.blockedAt = blockedAt
        self.callCount = callCount
        self.lastCallAt = lastCallAt
    }
    
    /// Increment the call count and update last call time
    func recordBlockedCall() {
        callCount += 1
        lastCallAt = Date()
    }
}

// MARK: - Block Reason

/// The reason a number was blocked
enum BlockReason: String, Codable, CaseIterable {
    /// Manually blocked by the user
    case manual
    
    /// Blocked because it matches a pattern
    case pattern
    
    /// Blocked because it's from a blocked country
    case country
    
    /// Identified as spam
    case spam
    
    var displayName: String {
        switch self {
        case .manual: return "Manually blocked"
        case .pattern: return "Pattern match"
        case .country: return "Country blocked"
        case .spam: return "Spam detected"
        }
    }
    
    var icon: String {
        switch self {
        case .manual: return "hand.raised.fill"
        case .pattern: return "number.square.fill"
        case .country: return "globe"
        case .spam: return "exclamationmark.shield.fill"
        }
    }
}

// MARK: - Convenience Extensions

extension BlockedNumber {
    /// Returns the phone number as an Int64 for CallKit
    /// CallKit requires numbers in ascending numerical order as Int64
    var numericPhoneNumber: Int64? {
        // Remove the + prefix and any non-numeric characters
        let digitsOnly = phoneNumber.replacingOccurrences(of: "+", with: "")
            .filter { $0.isNumber }
        return Int64(digitsOnly)
    }
    
    /// Formatted display string for the phone number
    var displayNumber: String {
        // If we have the raw number, show that for better readability
        if !rawNumber.isEmpty && rawNumber != phoneNumber {
            return rawNumber
        }
        return phoneNumber
    }
}
