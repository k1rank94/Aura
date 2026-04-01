//
//  TodayView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = TodayViewModel()
    @Query(sort: \TaskItem.createdAt, order: .forward) private var todayTasks: [TaskItem]
    @State private var taskToEdit: TaskItem?
    
    private var tasksForToday: [TaskItem] {
        todayTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }
    }
    
    var body: some View {
        List {
            headerSection
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            dailyGoalCard(tasks: tasksForToday)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            let morning = viewModel.morningTasks(from: tasksForToday)
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
            
            let afternoon = viewModel.afternoonTasks(from: tasksForToday)
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
            
            if tasksForToday.isEmpty {
                emptyStateView
                    .listRowInsets(EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            
            Spacer()
                .frame(height: 100)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .scrollIndicators(.hidden)
        .sheet(item: $taskToEdit) { task in
            AddTaskSheet(task: task) { _ in
                NotificationManager.shared.scheduleNotification(for: task)
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(32)
        }
    }
    
    @ViewBuilder
    private func taskRow(for task: TaskItem) -> some View {
        TaskRowView(task: task) {
            let isBecomingCompleted = !task.isCompleted
            viewModel.toggleTaskCompletion(task)
            
            if isBecomingCompleted, let newTask = task.generateNextOccurrence() {
                context.insert(newTask)
                NotificationManager.shared.scheduleNotification(for: newTask)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        // DARK MODE FIX: Adaptive Card Background
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .onTapGesture {
            taskToEdit = task
        }
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
                    // DARK MODE FIX: Adaptive Text Color
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
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
                    // DARK MODE FIX: Adaptive Text Color
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
        // DARK MODE FIX: Adaptive Card Background
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
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
