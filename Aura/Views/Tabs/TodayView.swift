//
//  TodayView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

/// A primary view that displays tasks scheduled for the current day.
///
/// `TodayView` acts as a daily dashboard for the user. It integrates the `TodayViewModel`
/// to split tasks into "Morning" and "Afternoon" sections and utilizes a `ProgressRingView`
/// to show a live progress tracker of their daily goals.
struct TodayView: View {
    
    // MARK: - Environment & State
    
    /// The SwiftData model context used for deletions.
    @Environment(\.modelContext) private var context
    
    /// The view model that manages task filtering and progress calculation.
    @State private var viewModel = TodayViewModel()
    
    /// All tasks stored in SwiftData, retrieved dynamically.
    @Query(sort: \TaskItem.createdAt, order: .forward) private var todayTasks: [TaskItem]
    
    /// The task currently selected by the user for editing.
    @State private var taskToEdit: TaskItem?
    
    // MARK: - Body
    
    var body: some View {
        List {
            
            // Dynamic Header Section
            headerSection
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            // Goal Tracking Card
            dailyGoalCard(tasks: todayTasks)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            // Flattened Morning Section
            let morning = viewModel.morningTasks(from: todayTasks)
            if !morning.isEmpty {
                Text("MORNING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .kerning(1.5)
                    .padding(.top, 8)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                ForEach(morning) { task in
                    taskRow(for: task)
                }
            }
            
            // Flattened Afternoon Section
            let afternoon = viewModel.afternoonTasks(from: todayTasks)
            if !afternoon.isEmpty {
                Text("AFTERNOON")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .kerning(1.5)
                    .padding(.top, 16)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                ForEach(afternoon) { task in
                    taskRow(for: task)
                }
            }
            
            // Empty State
            if todayTasks.isEmpty {
                emptyStateView
                    .listRowInsets(EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            // Bottom buffer to prevent content from being hidden behind the FAB
            Spacer()
                .frame(height: 100)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollIndicators(.hidden)
        
        // --- THE EDITING SHEET ---
        // Binds to taskToEdit. When a task is tapped, this sheet opens.
        .sheet(item: $taskToEdit) { task in
            AddTaskSheet(task: task) { _ in
                // SwiftData automatically saves changes via the context.
                // We ensure system notifications are rescheduled to reflect newly set times.
                NotificationManager.shared.scheduleNotification(for: task)
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
        }
    }
    
    // MARK: - Subviews
    
    /// Generates a customized list row for an individual task.
    ///
    /// - Parameter task: The `TaskItem` to represent in the UI.
    /// - Returns: A styled view equipped with interaction gestures.
    @ViewBuilder
    private func taskRow(for task: TaskItem) -> some View {
        TaskRowView(task: task) {
            viewModel.toggleTaskCompletion(task)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        
        // Present the task detail sheet when the row is tapped
        .onTapGesture {
            taskToEdit = task
        }
        
        // Destructive swipe action for task deletion
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    NotificationManager.shared.cancelNotification(for: task.id)
                    context.delete(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    /// The static header section displaying the view's title.
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TODAY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .kerning(1.2)
                
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    /// A dashboard card summarizing the user's progress for the day.
    ///
    /// - Parameter tasks: The collection of tasks currently displayed on the view.
    /// - Returns: A visual container integrating text and a custom `ProgressRingView`.
    private func dailyGoalCard(tasks: [TaskItem]) -> some View {
        HStack(spacing: 16) {
            ProgressRingView(progress: viewModel.calculateProgress(for: tasks))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY GOAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text("\(viewModel.remainingCount(for: tasks)) tasks remaining")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    /// A placeholder view shown when no tasks are currently assigned to "Today."
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 60)
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
                .padding(.bottom, 8)
            Text("No tasks for today.")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tap the + button to get started.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TodayView()
}
