//
//  AppGroupContainer.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

/// Provides access to the shared App Group container used by both
/// the main app and the Call Directory Extension
enum AppGroupContainer {
    /// The App Group identifier - must match the one configured in Xcode
    static let identifier = "group.com.reelsynth.Groot"
    
    /// The shared container URL for storing data accessible by both app and extension
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    /// Shared UserDefaults instance for app-extension communication
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
    
    /// The URL for the shared SwiftData store
    static var storeURL: URL? {
        containerURL?.appendingPathComponent("Groot.store")
    }
    
    // MARK: - Shared UserDefaults Keys
    
    /// Keys for values stored in shared UserDefaults
    enum DefaultsKey {
        static let lastSyncDate = "lastCallDirectorySyncDate"
        static let needsReload = "callDirectoryNeedsReload"
        static let blockUnknownCallers = "blockUnknownCallers"
        static let extensionEnabled = "callDirectoryExtensionEnabled"
        static let totalBlockedCount = "totalBlockedCallCount"
    }
    
    // MARK: - Sync Helpers
    
    /// Mark that the Call Directory needs to be reloaded
    static func markNeedsReload() {
        sharedDefaults?.set(true, forKey: DefaultsKey.needsReload)
    }
    
    /// Check if the Call Directory needs to be reloaded
    static var needsReload: Bool {
        sharedDefaults?.bool(forKey: DefaultsKey.needsReload) ?? false
    }
    
    /// Clear the needs reload flag
    static func clearNeedsReload() {
        sharedDefaults?.set(false, forKey: DefaultsKey.needsReload)
    }
    
    /// Update the last sync date
    static func updateLastSyncDate() {
        sharedDefaults?.set(Date(), forKey: DefaultsKey.lastSyncDate)
    }
    
    /// Get the last sync date
    static var lastSyncDate: Date? {
        sharedDefaults?.object(forKey: DefaultsKey.lastSyncDate) as? Date
    }
    
    /// Get/set whether to block unknown callers
    static var blockUnknownCallers: Bool {
        get { sharedDefaults?.bool(forKey: DefaultsKey.blockUnknownCallers) ?? false }
        set { sharedDefaults?.set(newValue, forKey: DefaultsKey.blockUnknownCallers) }
    }
    
    /// Increment the total blocked call count
    static func incrementBlockedCount() {
        let current = sharedDefaults?.integer(forKey: DefaultsKey.totalBlockedCount) ?? 0
        sharedDefaults?.set(current + 1, forKey: DefaultsKey.totalBlockedCount)
    }
    
    /// Get the total blocked call count
    static var totalBlockedCount: Int {
        sharedDefaults?.integer(forKey: DefaultsKey.totalBlockedCount) ?? 0
    }
}

// MARK: - SwiftData Container Factory

extension AppGroupContainer {
    /// Creates a ModelContainer configured for the shared App Group
    /// This should be used by both the main app and the extension
    static func createSharedModelContainer() throws -> ModelContainer {
        let schema = Schema([
            AppSettings.self,
            BlockedNumber.self,
            WhitelistContact.self,
            BlockedCountry.self,
            BlockPattern.self
        ])
        
        // Try to use the shared container URL, fall back to default if not available
        // (e.g., during development without App Group configured)
        let configuration: ModelConfiguration
        
        if let storeURL = storeURL {
            configuration = ModelConfiguration(
                schema: schema,
                url: storeURL,
                allowsSave: true
            )
        } else {
            // Fallback for when App Group isn't configured yet
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
        }
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Migration failed - delete the old store and try again
            print("SwiftData migration failed: \(error)")
            print("Attempting to delete old store and recreate...")
            
            if let storeURL = storeURL {
                deleteStore(at: storeURL)
            }
            
            // Also try to delete the default store location
            deleteDefaultStore()
            
            // Retry creating the container
            return try ModelContainer(for: schema, configurations: [configuration])
        }
    }
    
    /// Deletes the SwiftData store files at the given URL
    private static func deleteStore(at url: URL) {
        let fileManager = FileManager.default
        let storeFiles = [
            url,
            url.appendingPathExtension("shm"),
            url.appendingPathExtension("wal")
        ]
        
        for file in storeFiles {
            try? fileManager.removeItem(at: file)
        }
        print("Deleted store at: \(url.path)")
    }
    
    /// Deletes the default SwiftData store in the app's document directory
    private static func deleteDefaultStore() {
        guard let documentsURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let defaultStoreURL = documentsURL.appendingPathComponent("default.store")
        deleteStore(at: defaultStoreURL)
    }
    
    /// Creates a read-only ModelContainer for use in the Call Directory Extension
    /// The extension should primarily read data, not write
    static func createExtensionModelContainer() throws -> ModelContainer {
        let schema = Schema([
            BlockedNumber.self,
            WhitelistContact.self,
            BlockedCountry.self,
            BlockPattern.self
        ])
        
        guard let storeURL = storeURL else {
            throw AppGroupError.containerNotAvailable
        }
        
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: false // Read-only for extension
        )
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

// MARK: - Errors

enum AppGroupError: LocalizedError {
    case containerNotAvailable
    case storeNotFound
    
    var errorDescription: String? {
        switch self {
        case .containerNotAvailable:
            return "App Group container is not available. Please check that App Groups is enabled in Xcode."
        case .storeNotFound:
            return "Could not find the shared data store."
        }
    }
}
