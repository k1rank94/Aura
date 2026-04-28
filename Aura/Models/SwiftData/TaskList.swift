//
//  TaskList.swift
//  Aura
//
//  Created by Jules.
//

import Foundation
import SwiftData

/// Represents a specific list of tasks (e.g., "Groceries", "Sprint 1") within a Space
@Model
final class TaskList {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date

    var space: TaskSpace?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.list)
    var tasks: [TaskItem] = []

    init(id: UUID = UUID(), title: String = "", createdAt: Date = .now, space: TaskSpace? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.space = space
    }
}
