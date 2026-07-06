//
//  TaskSubtask.swift
//  Aura
//

import Foundation
import SwiftData

@Model
final class TaskSubtask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var sortOrder: Double
    var task: TaskItem?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        sortOrder: Double = 0,
        task: TaskItem? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.task = task
    }
}
