//
//  AuraWidgetSnapshotStore.swift
//  Aura
//

import Foundation
import WidgetKit

struct AuraWidgetSnapshot: Codable, Equatable {
    let openToday: Int
    let completedToday: Int
    let nextTaskTitle: String?
    let updatedAt: Date
}

enum AuraWidgetSnapshotStore {
    static let appGroup = "group.com.kiran.Aura"
    static let snapshotKey = "aura.widget.snapshot"

    static func save(tasks: [TaskItem]) {
        let today = tasks.filter {
            guard let dueDate = $0.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }
        let openTasks = today
            .filter { !$0.isCompleted }
            .sorted { ($0.dueDate ?? $0.createdAt) < ($1.dueDate ?? $1.createdAt) }
        let snapshot = AuraWidgetSnapshot(
            openToday: openTasks.count,
            completedToday: today.filter(\.isCompleted).count,
            nextTaskTitle: openTasks.first?.title,
            updatedAt: .now
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults(suiteName: appGroup)?.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "AuraTodayWidget")
    }
}
