//
//  AppState.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import Foundation

/// An observable object that manages the global state of the application.
///
/// `AppState` centralizes high-level application configurations, such as tracking
/// whether the user has completed the initial onboarding flow. It ensures that state
/// changes are automatically synchronized with persistent storage (e.g., `UserDefaults`).
@Observable
class AppState {
    
    /// A boolean value indicating whether the user has successfully completed the onboarding process.
    ///
    /// Updating this property automatically persists the new value to `UserDefaults`.
    private(set) var isUserOnboardingCompleted: Bool = false {
        didSet {
            UserDefaults.isOnboardingCompleted = isUserOnboardingCompleted
        }
    }
    
    /// Initializes a new application state.
    ///
    /// - Parameter isUserOnboardingCompleted: A predefined completion state. Defaults to the value stored in `UserDefaults`.
    init(isUserOnboardingCompleted: Bool = UserDefaults.isOnboardingCompleted) {
        self.isUserOnboardingCompleted = isUserOnboardingCompleted
    }
    
    /// Updates the onboarding completion status.
    ///
    /// - Parameter isCompleted: `true` if the user has completed onboarding, otherwise `false`.
    func setIsUserOnboardingCompleted(_ isCompleted: Bool) {
        self.isUserOnboardingCompleted = isCompleted
    }
}
