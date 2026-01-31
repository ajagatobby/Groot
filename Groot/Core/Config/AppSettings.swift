//
//  AppSettings.swift
//  Groot
//
//  Created by Abdulbasit Ajaga on 31/01/2026.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    // Onboarding
    var hasCompletedOnboarding: Bool
    var onboardingCompletedAt: Date?
    
    // Permissions setup
    var hasCompletedPermissions: Bool
    var permissionsCompletedAt: Date?
    
    // App preferences (for future use)
    var blockUnknownCallers: Bool
    var silentMode: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    
    // Stats
    var totalBlockedCalls: Int
    var appLaunchCount: Int
    var firstLaunchDate: Date
    
    init(
        hasCompletedOnboarding: Bool = false,
        onboardingCompletedAt: Date? = nil,
        hasCompletedPermissions: Bool = false,
        permissionsCompletedAt: Date? = nil,
        blockUnknownCallers: Bool = true,
        silentMode: Bool = false,
        hapticsEnabled: Bool = true,
        notificationsEnabled: Bool = true,
        totalBlockedCalls: Int = 0,
        appLaunchCount: Int = 0,
        firstLaunchDate: Date = Date()
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.onboardingCompletedAt = onboardingCompletedAt
        self.hasCompletedPermissions = hasCompletedPermissions
        self.permissionsCompletedAt = permissionsCompletedAt
        self.blockUnknownCallers = blockUnknownCallers
        self.silentMode = silentMode
        self.hapticsEnabled = hapticsEnabled
        self.notificationsEnabled = notificationsEnabled
        self.totalBlockedCalls = totalBlockedCalls
        self.appLaunchCount = appLaunchCount
        self.firstLaunchDate = firstLaunchDate
    }
}

// MARK: - Convenience Methods

extension AppSettings {
    func completeOnboarding() {
        hasCompletedOnboarding = true
        onboardingCompletedAt = Date()
    }
    
    func completePermissions() {
        hasCompletedPermissions = true
        permissionsCompletedAt = Date()
    }
    
    func incrementLaunchCount() {
        appLaunchCount += 1
    }
    
    /// Returns true if the full setup flow is complete
    var isFullySetUp: Bool {
        hasCompletedOnboarding && hasCompletedPermissions
    }
}
