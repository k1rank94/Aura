//
//  MainTabView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    
    @State private var selectedTab = 1
    @State private var isShowingAddTask = false
    
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
            }
            .tint(.pink)
            
            // 2. The Floating Action Button (FAB)
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
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
        // 3. The Creation Sheet
        .sheet(isPresented: $isShowingAddTask) {
            // Explicitly pass nil to create a NEW task
            AddTaskSheet(task: nil) { newTask in
                if let taskToSave = newTask {
                    context.insert(taskToSave)
                    
                    // Schedule notification for the new task
                    NotificationManager.shared.scheduleNotification(for: taskToSave)
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
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
