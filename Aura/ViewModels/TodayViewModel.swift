//
//  TodayViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import SwiftData

@Observable
class TodayViewModel {
    
    // 1. Calculate the Progress Ring (e.g., 68%)
    func calculateProgress(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    // 2. Calculate Tasks Remaining (e.g., 5 tasks remaining)
    func remainingCount(for tasks: [TaskItem]) -> Int {
        return tasks.filter { !$0.isCompleted }.count
    }
    
    // 3. Filter Morning Tasks (Before 12 PM)
    func morningTasks(from tasks: [TaskItem]) -> [TaskItem] {
        return tasks.filter { task in
            guard let date = task.dueDate else { return true } // Default to morning if no time
            let hour = Calendar.current.component(.hour, from: date)
            return hour < 12
        }
    }
    
    // 4. Filter Afternoon Tasks (12 PM or later)
    func afternoonTasks(from tasks: [TaskItem]) -> [TaskItem] {
        return tasks.filter { task in
            guard let date = task.dueDate else { return false }
            let hour = Calendar.current.component(.hour, from: date)
            return hour >= 12
        }
    }
    
    // 5. Toggle Completion
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        
        // Manage the notification state
        if task.isCompleted {
            NotificationManager.shared.cancelNotification(for: task.id)
        } else {
            // If they un-check it, reschedule the notification just in case
            NotificationManager.shared.scheduleNotification(for: task)
        }
    }
}
