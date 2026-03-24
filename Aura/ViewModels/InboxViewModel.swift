//
//  InboxViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import SwiftData

/// An observable view model that manages the business logic for the 'Inbox' view.
///
/// `InboxViewModel` processes tasks that do not have a specific due date. It provides
/// utility methods for calculating overall progress, determining pending task counts,
/// and securely toggling completion states.
@Observable
class InboxViewModel {
    
    /// Calculates the completion percentage for a given array of unscheduled tasks.
    ///
    /// - Parameter tasks: An array of `TaskItem` objects.
    /// - Returns: A decimal representing the completion percentage (e.g., `0.75` for 75%). Returns `0.0` if the array is empty.
    func calculateProgress(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    /// Counts the number of incomplete tasks in a given array.
    ///
    /// - Parameter tasks: An array of `TaskItem` objects.
    /// - Returns: The total number of tasks that are still pending.
    func pendingCount(for tasks: [TaskItem]) -> Int {
        return tasks.filter { !$0.isCompleted }.count
    }
    
    /// Toggles the completion status of a specific task.
    ///
    /// - Parameter task: The `TaskItem` to update.
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
    }
}
