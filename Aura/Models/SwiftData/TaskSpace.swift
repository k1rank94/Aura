//
//  TaskSpace.swift
//  Aura
//
//  Created by Jules.
//

import Foundation
import SwiftData

/// Represents a higher-level categorization for Lists (e.g., "Personal", "Work")
@Model
final class TaskSpace {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TaskList.space)
    var lists: [TaskList] = []

    init(id: UUID = UUID(), title: String = "", createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}
