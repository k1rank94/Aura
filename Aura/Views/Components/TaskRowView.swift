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

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .default))
                    .fontWeight(task.isCompleted ? .regular : .medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                HStack(spacing: 8) {
                    if let date = task.dueDate, !task.isCompleted {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if task.recurrence != nil, !task.isCompleted {
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    
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
            
            if !task.isCompleted {
                Circle()
                    .fill(priorityColor(for: task.priority))
                    .frame(width: 10, height: 10)
            }
        }
        // REDUCED: Tighter internal padding for a slimmer row
        .padding(.vertical, 4)
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
