//
//  InboxView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

/// A view that displays unscheduled tasks residing in the user's Inbox.
///
/// `InboxView` utilizes SwiftData to query all tasks where the `dueDate` is `nil`.
/// It provides a comprehensive overview of pending items and features a summary
/// card driven by `InboxViewModel`.
struct InboxView: View {
    
    // MARK: - Environment & State
    
    /// The SwiftData model context used to perform data mutations like deletions.
    @Environment(\.modelContext) private var context
    
    /// The view model that manages task progress and calculations.
    @State private var viewModel = InboxViewModel()
    
    /// A dynamically updating collection of tasks that do not have an assigned due date.
    @Query(
        filter: #Predicate<TaskItem> { $0.dueDate == nil },
        sort: \TaskItem.createdAt,
        order: .forward
    ) private var inboxTasks: [TaskItem]
    
    /// The task currently selected by the user for editing.
    /// Setting this property triggers the presentation of the `AddTaskSheet`.
    @State private var taskToEdit: TaskItem?
    
    // MARK: - Body
    
    var body: some View {
        List {
            
            // Dynamic Header Section
            headerSection
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            // Overall Progress Summary Card
            summaryCard(tasks: inboxTasks)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            // Render Pending Tasks
            ForEach(inboxTasks) { task in
                taskRow(for: task)
            }
            
            // Empty State Handling
            if inboxTasks.isEmpty {
                emptyStateView
                    .listRowInsets(EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            // Bottom padding for safe scrolling past the FAB
            Spacer()
                .frame(height: 100)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollIndicators(.hidden)
        
        // Detail sheet for editing an existing unscheduled task
        .sheet(item: $taskToEdit) { task in
            AddTaskSheet(task: task) { _ in
                // If the user adds a date during edit, it moves out of the inbox,
                // so we must ensure a notification is properly scheduled.
                NotificationManager.shared.scheduleNotification(for: task)
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
        }
    }
    
    // MARK: - Subviews
    
    /// Creates an interactive row for a given task.
    ///
    /// - Parameter task: The `TaskItem` to represent in the UI.
    /// - Returns: A `TaskRowView` with tap and swipe-to-delete gestures attached.
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
        
        // Triggers the edit sheet
        .onTapGesture {
            taskToEdit = task
        }
        
        // Swipe action to permanently delete the task
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
    
    /// The static header containing the view's titles.
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("UNSCHEDULED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .kerning(1.2)
                
                Text("Inbox")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    /// A dashboard card summarizing the overall progress of unscheduled tasks.
    ///
    /// - Parameter tasks: The collection of inbox tasks.
    /// - Returns: A visually distinct card combining a `ProgressRingView` and pending task counts.
    private func summaryCard(tasks: [TaskItem]) -> some View {
        HStack(spacing: 16) {
            ProgressRingView(progress: viewModel.calculateProgress(for: tasks))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("OVERALL PROGRESS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text("\(viewModel.pendingCount(for: tasks)) tasks pending")
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
    
    /// A placeholder view displayed when the user's Inbox is empty.
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 60)
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
                .padding(.bottom, 8)
            Text("Your inbox is empty.")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tasks without a date will appear here.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}
