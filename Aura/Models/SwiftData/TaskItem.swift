//
//  TaskItem.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import SwiftData

// MARK: - Priority

/// An enumeration representing the urgency or importance of a task.
///
/// `Priority` is `Codable` and backed by an `Int`, ensuring seamless persistence
/// within SwiftData and enabling chronological or logical sorting if needed.
enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
}

// MARK: - Recurrence (NEW)

/// An enumeration defining the frequency at which a task should repeat.
///
/// Backed by a `String` so it can be easily displayed in the UI (e.g., "Daily", "Weekly").
enum RecurrenceRule: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

// MARK: - Data Model

/// The core data model representing an individual task within the Aura application.
///
/// `TaskItem` is a SwiftData `@Model` that encapsulates all the details of a task,
/// including its schedule, categorization, completion status, and recurrence rules.
@Model
final class TaskItem {
    
    /// A unique identifier for the task, ensuring robust differentiation during updates or deletions.
    @Attribute(.unique) var id: UUID
    
    /// The primary display text of the task.
    var title: String
    
    /// A boolean flag indicating whether the user has finished the task.
    var isCompleted: Bool
    
    /// An optional target date and time for the task.
    ///
    /// If `dueDate` is `nil`, the task is considered unscheduled and defaults to the Inbox.
    /// If a date is provided, the task will appear in views like "Today" or "Upcoming."
    var dueDate: Date?
    
    /// The importance level of the task.
    var priority: Priority
    
    /// The exact timestamp when the task was initially created. Used for baseline sorting.
    var createdAt: Date
    
    /// An optional custom string used to visually categorize the task (e.g., "Work", "Health").
    var tag: String?
    
    // MARK: - New Migration Properties
    
    /// An optional rule defining if and how the task should repeat.
    ///
    /// **Migration Note:** This is marked as optional (`?`) so that existing users upgrading
    /// to this version will seamlessly receive `nil` (no recurrence) for their existing tasks
    /// without crashing the local SwiftData store.
    var recurrence: RecurrenceRule?
    
    /// An optional list this task belongs to.
    var list: TaskList?

    /// Initializes a new task with the provided configuration.
    init(
        id: UUID = UUID(),
        title: String = "",
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: Priority = .low,
        createdAt: Date = .now,
        tag: String? = nil,
        recurrence: RecurrenceRule? = nil, // Added to initializer safely
        list: TaskList? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.createdAt = createdAt
        self.tag = tag
        self.recurrence = recurrence
        self.list = list
    }
}
