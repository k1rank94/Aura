//
//  NotificationManager.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
@preconcurrency import UserNotifications

/// A singleton manager responsible for handling all local system notifications.
///
/// `NotificationManager` securely interacts with the `UNUserNotificationCenter`
/// to request permissions, schedule precise alerts for individual tasks,
/// and manage daily repeating briefing notifications.
///
/// The `@MainActor` attribute ensures thread safety across all UI-driven notification calls.
@MainActor
class NotificationManager {
    
    /// The shared singleton instance used globally across the app.
    static let shared = NotificationManager()
    
    // Private initializer to prevent accidental multiple instances
    private init() {}
    
    // MARK: - Core Permissions
    
    /// Prompts the user to authorize system-level notifications for the application.
    /// Best practice is to call this during onboarding or when the user first interacts with a reminder.
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Task-Specific Notifications
    
    /// Schedules a precise, one-time local notification for a specified task.
    ///
    /// The notification is only scheduled if the task is incomplete and its due date is in the future.
    ///
    /// - Parameter task: The `TaskItem` to schedule. Uses the task's unique `id` to prevent duplication.
    func scheduleNotification(for task: TaskItem) {
        guard let dueDate = task.dueDate, !task.isCompleted, dueDate > Date() else { return }

        let identifier = task.id.uuidString
        let title = task.title
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                Self.submitTaskNotification(
                    identifier: identifier,
                    title: title,
                    dueDate: dueDate
                )
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error {
                        print("Notification permission error: \(error.localizedDescription)")
                    }
                    guard granted else { return }
                    Self.submitTaskNotification(
                        identifier: identifier,
                        title: title,
                        dueDate: dueDate
                    )
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated private static func submitTaskNotification(
        identifier: String,
        title: String,
        dueDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = "A gentle reminder"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancels any pending notification requests associated with a specific task identifier.
    ///
    /// - Parameter taskID: The `UUID` of the task to unschedule.
    func cancelNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
    }
    
    // MARK: - Daily Briefing Notifications
    
    /// Configures the 8:00 AM daily morning briefing.
    ///
    /// - Parameter isEnabled: A boolean determining whether the repeating notification should be added or removed.
    func updateMorningBriefing(isEnabled: Bool) {
        let identifier = "aura_morning_briefing"
        
        // Always clear the existing pending request first to prevent duplicate stacking
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        if isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Good Morning! ☀️"
            content.body = "Tap here to plan out your day and review your upcoming tasks."
            content.sound = .default
            
            // Set the trigger specifically for 8:00 AM every day
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            
            // 'repeats: true' ensures this fires daily without needing to be rescheduled
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    /// Configures the 8:00 PM daily evening wind-down summary.
    ///
    /// - Parameter isEnabled: A boolean determining whether the repeating notification should be added or removed.
    func updateEveningBriefing(isEnabled: Bool) {
        let identifier = "aura_evening_briefing"
        
        // Clear existing request
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        if isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Time to wind down 🌙"
            content.body = "Let's see what you accomplished today. Great work!"
            content.sound = .default
            
            // Set the trigger specifically for 8:00 PM (20:00 military time)
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}
