//
//  AuraTaskRow.swift
//  Aura
//

import SwiftData
import SwiftUI

struct AuraTaskRow: View {
    @Environment(\.modelContext) private var context

    let task: TaskItem
    let onOpen: () -> Void

    @State private var completionPulse = false

    var body: some View {
        HStack(spacing: AuraSpace.md) {
            Button(action: toggleCompletion) {
                ZStack {
                    Circle()
                        .strokeBorder(checkColor.opacity(task.isCompleted ? 0 : 0.55), lineWidth: 1.8)
                        .background(Circle().fill(task.isCompleted ? checkColor : .clear))
                        .frame(width: 28, height: 28)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(completionPulse ? 1.18 : 1)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Complete task")

            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(task.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if hasMetadata {
                        HStack(spacing: 10) {
                            if let dueDate = task.dueDate {
                                Label(scheduleText(for: dueDate), systemImage: task.isOverdue ? "exclamationmark.circle.fill" : "clock")
                                    .foregroundStyle(task.isOverdue ? AuraColor.coral : .secondary)
                            }

                            if !task.subtasks.isEmpty {
                                Label("\(task.completedSubtaskCount)/\(task.subtasks.count)", systemImage: "checklist")
                            }

                            if let estimatedMinutes = task.estimatedMinutes {
                                Label("\(estimatedMinutes)m", systemImage: "hourglass")
                            }
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            priorityMark
        }
        .padding(.horizontal, AuraSpace.md)
        .padding(.vertical, 15)
        .auraCard(cornerRadius: 20)
        .contextMenu {
            Button(task.isCompleted ? "Mark Incomplete" : "Complete", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark") {
                toggleCompletion()
            }

            Button("Delete", systemImage: "trash", role: .destructive) {
                deleteTask()
            }
        }
    }

    private var hasMetadata: Bool {
        task.dueDate != nil || !task.subtasks.isEmpty || task.estimatedMinutes != nil
    }

    private var checkColor: Color {
        switch task.priority {
        case .low: AuraColor.violet
        case .medium: AuraColor.sun
        case .high: AuraColor.coral
        }
    }

    @ViewBuilder
    private var priorityMark: some View {
        if task.priority != .low && !task.isCompleted {
            Capsule()
                .fill(checkColor)
                .frame(width: 4, height: 26)
                .accessibilityLabel("\(task.priority == .high ? "High" : "Medium") priority")
        }
    }

    private func scheduleText(for date: Date) -> String {
        if task.isOverdue {
            return "Overdue"
        }
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return date.formatted(.dateTime.weekday(.abbreviated).day())
    }

    @MainActor
    private func toggleCompletion() {
        let willComplete = !task.isCompleted

        withAnimation(.spring(response: 0.36, dampingFraction: 0.7)) {
            task.toggleCompletion()
            completionPulse = true
        }

        HapticManager.shared.notification(type: willComplete ? .success : .warning)

        if willComplete, let nextTask = task.generateNextOccurrence() {
            context.insert(nextTask)
            NotificationManager.shared.scheduleNotification(for: nextTask)
        }

        Task {
            try? await Task.sleep(for: .milliseconds(220))
            await MainActor.run {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    completionPulse = false
                }
            }
        }
    }

    private func deleteTask() {
        NotificationManager.shared.cancelNotification(for: task.id)
        context.delete(task)
        HapticManager.shared.notification(type: .warning)
    }
}
