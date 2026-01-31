//
//  CallDirectoryHandler.swift
//  GrootCallDirectory
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import CallKit
import SwiftData

/// Call Directory Extension handler that provides blocking and identification
/// data to iOS's call blocking system
class CallDirectoryHandler: CXCallDirectoryProvider {
    
    // MARK: - Properties
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    // MARK: - CXCallDirectoryProvider
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        // Initialize the model container for reading blocking data
        do {
            modelContainer = try createModelContainer()
            modelContext = ModelContext(modelContainer!)
            
            // Check if this is an incremental update request
            if context.isIncremental {
                addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
                addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
            } else {
                addAllBlockingPhoneNumbers(to: context)
                addAllIdentificationPhoneNumbers(to: context)
            }
            
            // Update sync timestamp
            AppGroupContainer.updateLastSyncDate()
            AppGroupContainer.clearNeedsReload()
        } catch {
            // Log the error but don't fail - just complete with no entries
            // This happens when:
            // - The main app hasn't created the store yet
            // - There's a schema mismatch (user needs to delete and reinstall app)
            // - The store is corrupted
            print("GrootCallDirectory: Failed to create model container: \(error)")
            print("GrootCallDirectory: Extension will complete with no blocking entries")
        }
        
        // Always complete successfully - never cancel the request
        context.completeRequest()
    }
    
    // MARK: - Model Container Setup
    
    private func createModelContainer() throws -> ModelContainer {
        // Schema must match the main app EXACTLY to avoid migration
        let schema = Schema([
            AppSettings.self,
            BlockedNumber.self,
            WhitelistContact.self,
            BlockedCountry.self,
            BlockPattern.self
        ])
        
        // Try to use the shared App Group container
        guard let storeURL = AppGroupContainer.storeURL else {
            throw CallDirectoryError.containerNotAvailable
        }
        
        // Check if the store file exists - if not, the main app hasn't created it yet
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            throw CallDirectoryError.storeNotCreated
        }
        
        // Create a read-only configuration that won't attempt migration
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: false
        )
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
    // MARK: - Blocking Phone Numbers
    
    /// Add all blocked phone numbers (full reload)
    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        guard let modelContext = modelContext else { return }
        
        // Fetch all data needed for blocking
        let blockedNumbers = fetchAllBlockedNumbers()
        let whitelistedNumbers = fetchWhitelistedPhoneNumbers()
        let blockedCountries = fetchBlockedCountries()
        let patterns = fetchActivePatterns()
        
        // Collect all numbers to block, excluding whitelisted ones
        var numbersToBlock: Set<Int64> = []
        
        // Add explicitly blocked numbers
        for blocked in blockedNumbers {
            if let numeric = blocked.numericPhoneNumber,
               !whitelistedNumbers.contains(numeric) {
                numbersToBlock.insert(numeric)
            }
        }
        
        // Note: For country blocking, we would need a database of known numbers
        // from those countries, which is impractical. Instead, we rely on
        // the identification feature to label calls from blocked countries
        // and the app can notify users.
        
        // Sort numbers in ascending order (required by CallKit)
        let sortedNumbers = numbersToBlock.sorted()
        
        // Add blocking entries
        for number in sortedNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
    }
    
    /// Add or remove blocking phone numbers incrementally
    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // For incremental updates, we would track changes since last sync
        // For now, fall back to full reload
        // TODO: Implement incremental updates by tracking changes in UserDefaults
        addAllBlockingPhoneNumbers(to: context)
    }
    
    // MARK: - Identification Phone Numbers
    
    /// Add all identification entries (for caller ID labels)
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        guard let modelContext = modelContext else { return }
        
        // Fetch blocked numbers that have labels
        let blockedNumbers = fetchAllBlockedNumbers()
        
        // Collect numbers with identification labels
        var numbersWithLabels: [(Int64, String)] = []
        
        for blocked in blockedNumbers {
            if let numeric = blocked.numericPhoneNumber {
                let label = blocked.label ?? blocked.reason.displayName
                numbersWithLabels.append((numeric, label))
            }
        }
        
        // Sort by phone number (required by CallKit)
        numbersWithLabels.sort { $0.0 < $1.0 }
        
        // Add identification entries
        for (number, label) in numbersWithLabels {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: number,
                label: label
            )
        }
    }
    
    /// Add or remove identification phone numbers incrementally
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Fall back to full reload for now
        addAllIdentificationPhoneNumbers(to: context)
    }
    
    // MARK: - Data Fetching
    
    private func fetchAllBlockedNumbers() -> [BlockedNumber] {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<BlockedNumber>(
            sortBy: [SortDescriptor(\.phoneNumber)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch blocked numbers: \(error)")
            return []
        }
    }
    
    private func fetchWhitelistedPhoneNumbers() -> Set<Int64> {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<WhitelistContact>()
        
        do {
            let contacts = try modelContext.fetch(descriptor)
            return Set(contacts.compactMap { $0.numericPhoneNumber })
        } catch {
            print("Failed to fetch whitelisted contacts: \(error)")
            return []
        }
    }
    
    private func fetchBlockedCountries() -> [BlockedCountry] {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<BlockedCountry>()
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch blocked countries: \(error)")
            return []
        }
    }
    
    private func fetchActivePatterns() -> [BlockPattern] {
        guard let modelContext = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<BlockPattern>(
            predicate: #Predicate { $0.isEnabled }
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch patterns: \(error)")
            return []
        }
    }
}

// MARK: - CXCallDirectoryExtensionContextDelegate

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // Log the error for debugging
        print("Call Directory request failed: \(error.localizedDescription)")
        
        // An error occurred while adding blocking or identification entries
        // This could be due to:
        // - Entries added out of order
        // - Duplicate entries
        // - Memory limit exceeded
    }
}

// MARK: - Errors

enum CallDirectoryError: LocalizedError {
    case dataLoadFailed
    case containerNotAvailable
    case storeNotCreated
    case invalidPhoneNumber
    
    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "Failed to load blocking data."
        case .containerNotAvailable:
            return "Shared container is not available."
        case .storeNotCreated:
            return "Data store has not been created by the main app yet."
        case .invalidPhoneNumber:
            return "Invalid phone number format."
        }
    }
}
