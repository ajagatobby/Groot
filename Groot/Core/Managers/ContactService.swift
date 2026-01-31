//
//  ContactService.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import Contacts
import SwiftUI

/// Represents a contact from the iOS Contacts framework
struct ContactInfo: Identifiable, Hashable {
    let id: String  // CNContact identifier
    let firstName: String
    let lastName: String
    let phoneNumbers: [String]
    let thumbnailData: Data?
    
    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        if !first.isEmpty && !last.isEmpty {
            return "\(first)\(last)".uppercased()
        } else if !first.isEmpty {
            return String(firstName.prefix(2)).uppercased()
        } else if !last.isEmpty {
            return String(lastName.prefix(2)).uppercased()
        }
        return "?"
    }
    
    var primaryPhoneNumber: String? {
        phoneNumbers.first
    }
}

/// Service for accessing iOS Contacts
@Observable
final class ContactService {
    
    // MARK: - Singleton
    
    static let shared = ContactService()
    
    private let store = CNContactStore()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// The current authorization status
    var authorizationStatus: CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    /// Whether we have access to contacts
    var hasAccess: Bool {
        authorizationStatus == .authorized
    }
    
    /// Request access to contacts
    /// - Returns: True if access was granted
    @discardableResult
    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            print("Failed to request contacts access: \(error)")
            return false
        }
    }
    
    // MARK: - Fetching Contacts
    
    /// Fetch all contacts with phone numbers
    func fetchAllContacts() async throws -> [ContactInfo] {
        if !hasAccess {
            let granted = await requestAccess()
            if !granted {
                throw ContactServiceError.notAuthorized
            }
        }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        request.sortOrder = .givenName
        
        var contacts: [ContactInfo] = []
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    // Only include contacts with phone numbers
                    let phoneNumbers = contact.phoneNumbers.compactMap { phoneNumber -> String? in
                        let number = phoneNumber.value.stringValue
                        return PhoneNumberService.shared.parseToE164(number)
                    }
                    
                    guard !phoneNumbers.isEmpty else { return }
                    
                    let info = ContactInfo(
                        id: contact.identifier,
                        firstName: contact.givenName,
                        lastName: contact.familyName,
                        phoneNumbers: phoneNumbers,
                        thumbnailData: contact.thumbnailImageData
                    )
                    contacts.append(info)
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
        
        return contacts
    }
    
    /// Search contacts by name
    func searchContacts(query: String) async throws -> [ContactInfo] {
        guard hasAccess else {
            throw ContactServiceError.notAuthorized
        }
        
        guard !query.isEmpty else {
            return try await fetchAllContacts()
        }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let predicate = CNContact.predicateForContacts(matchingName: query)
        
        let cnContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        return cnContacts.compactMap { contact -> ContactInfo? in
            let phoneNumbers = contact.phoneNumbers.compactMap { phoneNumber -> String? in
                let number = phoneNumber.value.stringValue
                return PhoneNumberService.shared.parseToE164(number)
            }
            
            guard !phoneNumbers.isEmpty else { return nil }
            
            return ContactInfo(
                id: contact.identifier,
                firstName: contact.givenName,
                lastName: contact.familyName,
                phoneNumbers: phoneNumbers,
                thumbnailData: contact.thumbnailImageData
            )
        }
    }
    
    /// Fetch a specific contact by identifier
    func fetchContact(identifier: String) async throws -> ContactInfo? {
        guard hasAccess else {
            throw ContactServiceError.notAuthorized
        }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        
        guard let contact = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).first else {
            return nil
        }
        
        let phoneNumbers = contact.phoneNumbers.compactMap { phoneNumber -> String? in
            let number = phoneNumber.value.stringValue
            return PhoneNumberService.shared.parseToE164(number)
        }
        
        return ContactInfo(
            id: contact.identifier,
            firstName: contact.givenName,
            lastName: contact.familyName,
            phoneNumbers: phoneNumbers,
            thumbnailData: contact.thumbnailImageData
        )
    }
    
    /// Find contact name for a phone number
    func findContactName(for phoneNumber: String) async throws -> String? {
        guard hasAccess else { return nil }
        
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        let phoneValue = CNPhoneNumber(stringValue: phoneNumber)
        let predicate = CNContact.predicateForContacts(matching: phoneValue)
        
        guard let contact = try? store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).first else {
            return nil
        }
        
        return [contact.givenName, contact.familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

// MARK: - Errors

enum ContactServiceError: LocalizedError {
    case notAuthorized
    case fetchFailed
    case contactNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Access to contacts is not authorized. Please enable it in Settings."
        case .fetchFailed:
            return "Failed to fetch contacts."
        case .contactNotFound:
            return "Contact not found."
        }
    }
}
