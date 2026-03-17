//
//  NotificationManager.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import UserNotifications

// @MainActor ensures this runs safely on the main thread, 
// which is a great Swift 6 concurrency practice to show off.
@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {} // Prevents creating multiple instances
    
    // 1. Ask the user for permission
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. Schedule a notification for a specific task
    func scheduleNotification(for task: TaskItem) {
        // Only schedule if it has a future date and isn't already completed
        guard let dueDate = task.dueDate, !task.isCompleted, dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        
        // Extract the exact minute/hour/day from the task's due date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Use the TaskItem's unique UUID as the notification identifier!
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 3. Cancel a notification (used when a task is deleted or completed)
    func cancelNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
    }
}