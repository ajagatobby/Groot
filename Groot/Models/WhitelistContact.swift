//
//  WhitelistContact.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a whitelisted contact that should never be blocked
@Model
final class WhitelistContact {
    /// The phone number in E.164 format
    @Attribute(.unique) var phoneNumber: String
    
    /// The contact's display name
    var name: String
    
    /// The iOS Contacts framework identifier (if imported from contacts)
    var contactIdentifier: String?
    
    /// When this contact was added to the whitelist
    var addedAt: Date
    
    /// Number of calls allowed through from this contact
    var callsAllowed: Int
    
    /// Optional thumbnail image data for the contact
    var thumbnailData: Data?
    
    init(
        phoneNumber: String,
        name: String,
        contactIdentifier: String? = nil,
        addedAt: Date = Date(),
        callsAllowed: Int = 0,
        thumbnailData: Data? = nil
    ) {
        self.phoneNumber = phoneNumber
        self.name = name
        self.contactIdentifier = contactIdentifier
        self.addedAt = addedAt
        self.callsAllowed = callsAllowed
        self.thumbnailData = thumbnailData
    }
    
    /// Record that a call was allowed through
    func recordAllowedCall() {
        callsAllowed += 1
    }
}

// MARK: - Convenience Extensions

extension WhitelistContact {
    /// Returns the phone number as an Int64 for CallKit comparisons
    var numericPhoneNumber: Int64? {
        let digitsOnly = phoneNumber.replacingOccurrences(of: "+", with: "")
            .filter { $0.isNumber }
        return Int64(digitsOnly)
    }
    
    /// Returns initials for avatar display
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
    
    /// Check if this contact was imported from iOS Contacts
    var isFromContacts: Bool {
        contactIdentifier != nil
    }
}
