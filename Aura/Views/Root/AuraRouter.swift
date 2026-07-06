//
//  AuraRouter.swift
//  Aura
//

import Foundation
import Observation

enum AuraTab: String, CaseIterable, Identifiable {
    case today
    case plan
    case library

    var id: Self { self }

    var title: String {
        switch self {
        case .today: "Today"
        case .plan: "Plan"
        case .library: "Library"
        }
    }

    var symbol: String {
        switch self {
        case .today: "sparkles"
        case .plan: "calendar"
        case .library: "square.grid.2x2"
        }
    }
}

enum AuraSheet: Identifiable {
    case quickCapture
    case editTask(TaskItem)
    case settings

    var id: String {
        switch self {
        case .quickCapture: "quick-capture"
        case .editTask(let task): "edit-\(task.id.uuidString)"
        case .settings: "settings"
        }
    }
}

@MainActor
@Observable
final class AuraRouter {
    var selectedTab: AuraTab = .today
    var presentedSheet: AuraSheet?

    func showQuickCapture() {
        presentedSheet = .quickCapture
    }

    func edit(_ task: TaskItem) {
        presentedSheet = .editTask(task)
    }
}
