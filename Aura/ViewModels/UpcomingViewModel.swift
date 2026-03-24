//
//  UpcomingViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import SwiftData

/// An observable view model that manages the logic for scheduling and filtering upcoming tasks.
///
/// `UpcomingViewModel` generates the date ranges for the calendar UI and filters
/// scheduled tasks based on the user's selected date.
@Observable
class UpcomingViewModel {
    
    /// The specific future date currently selected by the user.
    var selectedDate: Date
    
    /// Initializes the view model and defaults the selected date to tomorrow.
    init() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        self.selectedDate = Calendar.current.startOfDay(for: tomorrow)
    }
    
    /// A dynamically generated array representing the next 14 days, starting from tomorrow.
    ///
    /// This array powers the horizontal calendar scroller at the top of the upcoming view.
    var upcomingDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (1...14).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    /// Filters a general list of tasks, returning only those scheduled on the `selectedDate`.
    ///
    /// - Parameter tasks: The array of `TaskItem` objects to evaluate.
    /// - Returns: A filtered array containing only tasks matching the selected day.
    func tasksForSelectedDate(from tasks: [TaskItem]) -> [TaskItem] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }
    
    /// Toggles the completion status of a specific task and synchronizes its notification.
    ///
    /// - Parameter task: The `TaskItem` to update.
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        
        // Manage the notification state securely
        if task.isCompleted {
            NotificationManager.shared.cancelNotification(for: task.id)
        } else {
            // Reschedule the notification if the user marks the task as incomplete
            NotificationManager.shared.scheduleNotification(for: task)
        }
    }
    
    // MARK: - Date Formatting Helpers
    
    /// Returns an abbreviated, uppercase string for the day of the week (e.g., "MON").
    ///
    /// - Parameter date: The target `Date`.
    func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" 
        return formatter.string(from: date).uppercased()
    }
    
    /// Returns the day of the month as a string (e.g., "16").
    ///
    /// - Parameter date: The target `Date`.
    func dayOfMonth(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" 
        return formatter.string(from: date)
    }
}
