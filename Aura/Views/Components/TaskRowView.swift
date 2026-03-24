//
//  TaskRowView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

/// A reusable UI component representing a single task in a list.
///
/// `TaskRowView` encapsulates the visual layout for a task, including its completion
/// checkbox, title, scheduled time, tags, and priority indicator.
struct TaskRowView: View {
    
    /// The task object to display.
    let task: TaskItem
    
    /// A closure executed when the user interacts with the completion checkbox.
    let onToggleCompleted: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            
            // Interactive, bouncy circular checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onToggleCompleted()
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .gray : .pink)
            }
            .buttonStyle(.plain)

            // Core Task Details (Title, Time, Category)
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .default))
                    .fontWeight(task.isCompleted ? .regular : .medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                HStack(spacing: 8) {
                    // Display Contextual Time
                    if let date = task.dueDate, !task.isCompleted {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Display Categorization Tag
                    if let tag = task.tag, !task.isCompleted {
                        Text(tag.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // Priority Indicator Dot
            if !task.isCompleted {
                Circle()
                    .fill(priorityColor(for: task.priority))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
        // Ensure the entire row area registers tap gestures for editing
        .contentShape(Rectangle())
    }
    
    /// Maps a `Priority` enum to a standard color representation.
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        // Example: High-priority, scheduled task with a tag
        TaskRowView(
            task: TaskItem(
                title: "Review Q3 marketing plan",
                isCompleted: false,
                dueDate: .now,
                priority: .medium,
                tag: "Work"
            ),
            onToggleCompleted: {}
        )
        
        // Example: Completed, low-priority task
        TaskRowView(
            task: TaskItem(
                title: "Approve wireframes",
                isCompleted: true,
                priority: .low
            ),
            onToggleCompleted: {}
        )
    }
    .padding()
}
