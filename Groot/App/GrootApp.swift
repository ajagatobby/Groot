//
//  GrootApp.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import SwiftUI
import SwiftData

@main
struct GrootApp: App {
    /// Shared model container using App Group for extension access
    var sharedModelContainer: ModelContainer = {
        do {
            return try AppGroupContainer.createSharedModelContainer()
        } catch {
            // Log the error and fall back to non-shared container
            print("Failed to create shared container: \(error)")
            print("Falling back to local container...")
            
            // Fallback container without App Group
            let schema = Schema([
                AppSettings.self,
                BlockedNumber.self,
                WhitelistContact.self,
                BlockedCountry.self,
                BlockPattern.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                // Last resort - try deleting the default store
                print("Fallback also failed: \(error)")
                print("Deleting default store and retrying...")
                
                if let documentsURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    let defaultStoreURL = documentsURL.appendingPathComponent("default.store")
                    try? FileManager.default.removeItem(at: defaultStoreURL)
                    try? FileManager.default.removeItem(at: defaultStoreURL.appendingPathExtension("shm"))
                    try? FileManager.default.removeItem(at: defaultStoreURL.appendingPathExtension("wal"))
                }
                
                do {
                    return try ModelContainer(for: schema, configurations: [modelConfiguration])
                } catch {
                    fatalError("Could not create ModelContainer after cleanup: \(error)")
                }
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
