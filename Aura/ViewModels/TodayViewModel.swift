//
//  TodayViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import SwiftData

/// An observable view model that manages the business logic for the 'Today' view.
///
/// `TodayViewModel` isolates data processing from the UI, handling calculations for progress tracking
/// and categorization of tasks into morning or afternoon blocks. It also securely manages task state updates.
@Observable
class TodayViewModel {
    
    /// Calculates the completion percentage of a given list of tasks.
    ///
    /// - Parameter tasks: An array of `TaskItem` objects.
    /// - Returns: A decimal representing the completion percentage (e.g., `0.68` for 68%). Returns `0.0` if the array is empty.
    func calculateProgress(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    /// Counts the number of incomplete tasks in a given array.
    ///
    /// - Parameter tasks: An array of `TaskItem` objects.
    /// - Returns: The total number of tasks that are not yet marked as completed.
    func remainingCount(for tasks: [TaskItem]) -> Int {
        return tasks.filter { !$0.isCompleted }.count
    }
    
    /// Filters tasks scheduled for the morning (before 12 PM).
    ///
    /// - Parameter tasks: The array of `TaskItem` objects to filter.
    /// - Returns: An array containing tasks due before 12 PM, or tasks without specific times.
    func morningTasks(from tasks: [TaskItem]) -> [TaskItem] {
        return tasks.filter { task in
            guard let date = task.dueDate else { return true } // Default to morning if no time is specified
            let hour = Calendar.current.component(.hour, from: date)
            return hour < 12
        }
    }
    
    /// Filters tasks scheduled for the afternoon or evening (12 PM or later).
    ///
    /// - Parameter tasks: The array of `TaskItem` objects to filter.
    /// - Returns: An array containing tasks due at or after 12 PM.
    func afternoonTasks(from tasks: [TaskItem]) -> [TaskItem] {
        return tasks.filter { task in
            guard let date = task.dueDate else { return false }
            let hour = Calendar.current.component(.hour, from: date)
            return hour >= 12
        }
    }
    
    /// Toggles the completion status of a specific task and updates its corresponding system notification.
    ///
    /// - Parameter task: The `TaskItem` to update.
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        
        // Synchronize the notification state with the updated completion status
        if task.isCompleted {
            NotificationManager.shared.cancelNotification(for: task.id)
        } else {
            // Reschedule the notification in case the task is manually unchecked
            NotificationManager.shared.scheduleNotification(for: task)
        }
    }
}
