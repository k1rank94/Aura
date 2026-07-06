//
//  TaskItem+Presentation.swift
//  Aura
//

import Foundation

extension TaskItem {
    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: .now)
    }

    var completedSubtaskCount: Int {
        subtasks.filter(\.isCompleted).count
    }

    var sortedSubtasks: [TaskSubtask] {
        subtasks.sorted {
            if $0.sortOrder == $1.sortOrder {
                return $0.createdAt < $1.createdAt
            }
            return $0.sortOrder < $1.sortOrder
        }
    }

    @MainActor
    func setCompleted(_ completed: Bool) {
        isCompleted = completed
        completedAt = completed ? .now : nil

        if completed {
            NotificationManager.shared.cancelNotification(for: id)
        } else {
            NotificationManager.shared.scheduleNotification(for: self)
        }
    }

    @MainActor
    func toggleCompletion() {
        setCompleted(!isCompleted)
    }
}
