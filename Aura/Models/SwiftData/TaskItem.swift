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

// MARK: - Data Model

/// The core data model representing an individual task within the Aura application.
///
/// `TaskItem` is a SwiftData `@Model` that encapsulates all the details of a task,
/// including its schedule, categorization, and completion status.
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
    
    /// Initializes a new task with the provided configuration.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new `UUID`.
    ///   - title: The name of the task. Defaults to an empty string.
    ///   - isCompleted: The initial completion state. Defaults to `false`.
    ///   - dueDate: An optional target completion date. Defaults to `nil`.
    ///   - priority: The initial importance level. Defaults to `.low`.
    ///   - createdAt: The timestamp of creation. Defaults to the current date/time.
    ///   - tag: An optional categorization label. Defaults to `nil`.
    init(
        id: UUID = UUID(),
        title: String = "",
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: Priority = .low,
        createdAt: Date = .now,
        tag: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.createdAt = createdAt
        self.tag = tag
    }
}
