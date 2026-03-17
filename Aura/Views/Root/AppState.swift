//
//  AppState.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import Foundation

@Observable
class AppState {
    
    private(set) var isUserOnboardingCompleted: Bool = false {
        didSet {
            UserDefaults.isOnboardingCompleted = isUserOnboardingCompleted
        }
    }
    
    init(isUserOnboardingCompleted: Bool = UserDefaults.isOnboardingCompleted) {
        self.isUserOnboardingCompleted = isUserOnboardingCompleted
    }
    
    func setIsUserOnboardingCompleted(_ isCompleted: Bool) {
        self.isUserOnboardingCompleted = isCompleted
    }
}
