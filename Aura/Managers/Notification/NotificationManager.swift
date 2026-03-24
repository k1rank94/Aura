//
//  NotificationManager.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import UserNotifications

/// A singleton manager responsible for handling local system notifications.
///
/// `NotificationManager` securely interacts with the `UNUserNotificationCenter`
/// to request user permissions, schedule future alerts tied to specific tasks,
/// and cancel existing alerts when tasks are modified or deleted.
///
/// The `@MainActor` attribute ensures thread safety across all UI-driven notification calls.
@MainActor
class NotificationManager {
    
    /// The shared singleton instance.
    static let shared = NotificationManager()
    
    // Prevent external initializations
    private init() {} 
    
    /// Prompts the user to authorize system-level notifications for the application.
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedules a precise local notification for a specified task.
    ///
    /// The notification will only be scheduled if the task is incomplete and its target
    /// due date resides in the future. It uses the exact temporal components (down to the minute)
    /// to trigger the system alert.
    ///
    /// - Parameter task: The `TaskItem` to schedule. Uses the task's UUID to prevent duplication.
    func scheduleNotification(for task: TaskItem) {
        guard let dueDate = task.dueDate, !task.isCompleted, dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        
        // Extract the target time configuration from the task's due date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Bind the notification request to the TaskItem's stable identifier
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancels any pending notification requests associated with a specific task identifier.
    ///
    /// Commonly invoked when a task is marked as complete, deleted, or rescheduled.
    ///
    /// - Parameter taskID: The `UUID` of the task to unschedule.
    func cancelNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
    }
}
