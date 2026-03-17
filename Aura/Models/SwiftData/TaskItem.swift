//
//  Priority.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import SwiftData

// 1. The Priority Enum
// We make it Codable so SwiftData knows how to save it automatically.
enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
}

// 2. The Data Model
@Model
final class TaskItem {
    // Unique identifier for each task
    @Attribute(.unique) var id: UUID
    
    // Core properties
    var title: String
    var isCompleted: Bool
    
    // Optional date: If this is nil, the task lives in the "Inbox"
    // If it has a date, it shows up in "Today" or "Upcoming"
    var dueDate: Date? 
    
    var priority: Priority
    var createdAt: Date
    var tag: String?
    
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
