//
//  UpcomingViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import SwiftData

@Observable
class UpcomingViewModel {
    // Default to tomorrow
    var selectedDate: Date
    
    init() {
        // Set default selected date to tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        self.selectedDate = Calendar.current.startOfDay(for: tomorrow)
    }
    
    // Generate the next 14 days for the top calendar scroll
    var upcomingDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (1...14).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    // Filter the raw database array to only show tasks for the tapped date
    func tasksForSelectedDate(from tasks: [TaskItem]) -> [TaskItem] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }
    
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
    
    // Helpers for the calendar UI
    func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // e.g., "Mon"
        return formatter.string(from: date).uppercased()
    }
    
    func dayOfMonth(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // e.g., "16"
        return formatter.string(from: date)
    }
}
