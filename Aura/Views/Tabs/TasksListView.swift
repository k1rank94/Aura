//
//  TasksListView.swift
//  Aura
//
//  Created by Jules.
//

import SwiftUI
import SwiftData

struct TasksListView: View {
    @Environment(\.modelContext) private var context
    var list: TaskList

    @State private var taskToEdit: TaskItem?

    var body: some View {
        List {
            ForEach(list.tasks.sorted(by: { $0.createdAt < $1.createdAt })) { task in
                taskRow(for: task)
            }
            if list.tasks.isEmpty {
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
        .navigationTitle(list.title)
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
            task.isCompleted.toggle()
            // We duplicate the generation logic for occurrences simply here or handle within TaskRowView
            if isBecomingCompleted, let newTask = task.generateNextOccurrence() {
                context.insert(newTask)
                NotificationManager.shared.scheduleNotification(for: newTask)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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

    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 60)
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
                .padding(.bottom, 8)
            Text("This list is empty.")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Add tasks to see them here.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}
