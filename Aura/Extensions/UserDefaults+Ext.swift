//
//  UserDefaults+Ext.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import Foundation

extension UserDefaults {
    static var isOnboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isOnboardingCompleted)
        } set {
            UserDefaults.standard.set(newValue, forKey: Keys.isOnboardingCompleted)
        }
    }
}

