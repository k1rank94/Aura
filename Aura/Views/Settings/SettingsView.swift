//
//  SettingsView.swift
//  Aura
//
//  Created by Kiran on 31/03/26.
//

import SwiftUI

/// The user preferences screen.
///
/// `SettingsView` allows users to configure global app behavior, such as opting
/// into daily push notifications. It uses `@AppStorage` to automatically persist
/// state across app launches without requiring explicit SwiftData models.
struct SettingsView: View {
    
    // MARK: - State
    
    /// Tracks whether the user wants an 8:00 AM daily notification. Defaults to `true`.
    /// Modifying this toggle automatically updates the underlying `UserDefaults` value globally.
    @AppStorage("isMorningBriefingEnabled") private var isMorningBriefingEnabled = true
    
    /// Tracks whether the user wants an 8:00 PM daily notification. Defaults to `true`.
    /// Modifying this toggle automatically updates the underlying `UserDefaults` value globally.
    @AppStorage("isEveningBriefingEnabled") private var isEveningBriefingEnabled = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Morning Toggle
                    Toggle("Morning Briefing (8:00 AM)", isOn: $isMorningBriefingEnabled)
                        .tint(.pink)
                        // Listen for explicit user interactions to update the notification schedule immediately
                        .onChange(of: isMorningBriefingEnabled) { _, newValue in
                            NotificationManager.shared.updateMorningBriefing(isEnabled: newValue)
                        }
                    
                    // Evening Toggle
                    Toggle("Evening Briefing (8:00 PM)", isOn: $isEveningBriefingEnabled)
                        .tint(.pink)
                        // Listen for explicit user interactions to update the notification schedule immediately
                        .onChange(of: isEveningBriefingEnabled) { _, newValue in
                            NotificationManager.shared.updateEveningBriefing(isEnabled: newValue)
                        }
                } header: {
                    Text("Daily Nudges")
                } footer: {
                    Text("Get notified in the morning to plan your day, and in the evening to review your progress.")
                }
            }
            .navigationTitle("Settings")
            // Use the grouped background color to match native iOS Settings
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    SettingsView()
}
