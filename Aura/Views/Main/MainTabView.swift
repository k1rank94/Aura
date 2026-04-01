//
//  MainTabView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

/// The primary container view presented after onboarding.
///
/// `MainTabView` orchestrates the core navigational structure of the application. It hosts
/// five distinct sub-views (Inbox, Today, Upcoming, Search, and Settings) while providing a persistent,
/// global Floating Action Button (FAB) that allows users to create new tasks from any context.
struct MainTabView: View {
    
    // MARK: - Environment & State
    
    /// The SwiftData model context used to persist newly created tasks.
    @Environment(\.modelContext) private var context
    
    /// The currently selected tab index. Defaults to the 'Today' view (index 1).
    @State private var selectedTab = 1
    
    /// A boolean flag determining whether the global task creation sheet is currently visible.
    @State private var isShowingAddTask = false
    
    // The version the user last launched. Defaults to empty so fresh installs see it immediately.
    @AppStorage("lastLaunchedVersion") private var lastLaunchedVersion: String = ""
    
    // Controls the presentation of the What's New sheet
    @State private var isShowingWhatsNew = false
    
    // Extract the current app version directly from Xcode's Build settings
    private let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // MARK: - User Preferences
    
    /// Tracks whether the morning briefing is enabled. Defaults to `true`.
    /// Reading this here ensures the app can apply the user's preference (or the default value on first launch)
    /// to the notification system as soon as the main interface loads.
    @AppStorage("isMorningBriefingEnabled") private var isMorningBriefingEnabled = true
    
    /// Tracks whether the evening briefing is enabled. Defaults to `true`.
    /// Shares the exact same underlying `UserDefaults` key as the toggle in `SettingsView`.
    @AppStorage("isEveningBriefingEnabled") private var isEveningBriefingEnabled = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // 1. The Main Navigation Tabs
            TabView(selection: $selectedTab) {
                
                InboxView()
                    .tabItem {
                        Label("Inbox", systemImage: "tray")
                    }
                    .tag(0)
                
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "calendar")
                    }
                    .tag(1)
                
                UpcomingView()
                    .tabItem {
                        Label("Upcoming", systemImage: "tray.and.arrow.down")
                    }
                    .tag(2)
                
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(3)
                
                // NEW: The Settings Router
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(4)
            }
            .tint(.pink)
            
            // 2. The Floating Action Button (FAB)
            Button(action: {
                // Trigger tactile feedback on FAB interaction
                HapticManager.shared.impact(style: .light)
                isShowingAddTask = true
            }) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.pink)
                    .clipShape(Circle())
                    .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 80)
        }
        .onAppear {
            // Synchronize the NotificationManager with the user's stored preferences upon app launch.
            // This is crucial for the very first time the user opens the app, as the default `true`
            // values from `@AppStorage` need to be explicitly passed to the notification engine
            // to schedule the briefings.
            NotificationManager.shared.updateMorningBriefing(isEnabled: isMorningBriefingEnabled)
            NotificationManager.shared.updateEveningBriefing(isEnabled: isEveningBriefingEnabled)
            
            if lastLaunchedVersion != currentAppVersion {
                // Add a tiny delay so the UI finishes loading before popping the modal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowingWhatsNew = true
                }
            }
        }
        
        // 3. The Global Creation Sheet
        .sheet(isPresented: $isShowingAddTask) {
            // Explicitly pass nil to trigger "Create" mode rather than "Edit" mode
            AddTaskSheet(task: nil) { newTask in
                if let taskToSave = newTask {
                    // Save to the local SQLite database
                    context.insert(taskToSave)
                    
                    // Schedule a precise local notification for the newly saved task
                    NotificationManager.shared.scheduleNotification(for: taskToSave)
                    
                    // Trigger a success haptic to confirm creation to the user
                    HapticManager.shared.notification(type: .success)
                }
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
        }
        
        // What's New Presentation
        .sheet(isPresented: $isShowingWhatsNew, onDismiss: {
            // Once they dismiss it, save the new version so they don't see it again until the next update!
            lastLaunchedVersion = currentAppVersion
        }) {
            WhatsNewView(items: [
                WhatsNewItem(icon: "moon.stars.fill", title: "Dark Mode", description: "Aura now beautifully adapts to your system's dark mode settings for late-night planning.", color: .indigo),
                WhatsNewItem(icon: "repeat", title: "Recurring Tasks", description: "Automate your workflow. Set tasks to repeat daily, weekly, or monthly.", color: .pink),
                WhatsNewItem(icon: "bell.badge.fill", title: "Daily Nudges", description: "Start your morning right and wind down easily with automated daily briefing notifications.", color: .orange)
            ])
        }
    }
}

#Preview {
    MainTabView()
}
