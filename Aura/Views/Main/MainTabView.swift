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
/// four distinct sub-views (Inbox, Today, Upcoming, and Search) while providing a persistent,
/// global Floating Action Button (FAB) that allows users to create new tasks from any context.
struct MainTabView: View {
    
    // MARK: - Environment & State
    
    /// The SwiftData model context used to persist newly created tasks.
    @Environment(\.modelContext) private var context
    
    /// The currently selected tab index. Defaults to the 'Today' view (index 1).
    @State private var selectedTab = 1
    
    /// A boolean flag determining whether the global task creation sheet is currently visible.
    @State private var isShowingAddTask = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // The Main Navigation Tabs
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
            }
            .tint(.pink)
            
            // The Floating Action Button (FAB)
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
        
        // The Creation Sheet
        .sheet(isPresented: $isShowingAddTask) {
            // Explicitly pass nil to create a NEW task
            AddTaskSheet(task: nil) { newTask in
                if let taskToSave = newTask {
                    context.insert(taskToSave)
                    
                    // Schedule a local notification for the newly saved task
                    NotificationManager.shared.scheduleNotification(for: taskToSave)
                    
                    // Trigger a success haptic to confirm creation
                    HapticManager.shared.notification(type: .success)
                }
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
        }
    }
}

#Preview {
    MainTabView()
}
