//
//  TaskRowView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import SwiftUI
import SwiftData

struct TaskRowView: View {
    let task: TaskItem
    let onToggleCompleted: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            
            // 1. Bouncy Circular Checkbox
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

            // 2. Task Title, Time, and Tag
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .default))
                    .fontWeight(task.isCompleted ? .regular : .medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                HStack(spacing: 8) {
                    // Show Time/Date
                    if let date = task.dueDate, !task.isCompleted {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Show Tag Pill
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
            
            // 3. Priority Dot
            if !task.isCompleted {
                Circle()
                    .fill(priorityColor(for: task.priority))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
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
        // Uncompleted Task Example with Date and Tag
        TaskRowView(
            task: TaskItem(title: "Review Q3 marketing plan", isCompleted: false, dueDate: .now, priority: .medium, tag: "Work"),
            onToggleCompleted: {}
        )
        
        // Completed Task Example
        TaskRowView(
            task: TaskItem(title: "Approve wireframes", isCompleted: true, priority: .low),
            onToggleCompleted: {}
        )
    }
    .padding()
}
