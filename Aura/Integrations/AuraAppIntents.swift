//
//  AuraAppIntents.swift
//  Aura
//

import AppIntents
import Observation

enum AuraIntentDestination: String, AppEnum {
    case today
    case plan
    case library

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Aura section"

    static let caseDisplayRepresentations: [AuraIntentDestination: DisplayRepresentation] = [
        .today: "Today",
        .plan: "Plan",
        .library: "Library"
    ]

    var tab: AuraTab {
        switch self {
        case .today: .today
        case .plan: .plan
        case .library: .library
        }
    }
}

enum AuraIntentAction: Equatable {
    case open(AuraTab)
    case quickCapture(prefill: String)
}

@MainActor
@Observable
final class AuraIntentRouter {
    static let shared = AuraIntentRouter()
    var pendingAction: AuraIntentAction?

    private init() {}
}

struct OpenAuraSectionIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Aura"
    static let description = IntentDescription("Open a section in Aura.")
    static let openAppWhenRun = true

    @Parameter(title: "Section")
    var destination: AuraIntentDestination

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AuraIntentRouter.shared.pendingAction = .open(destination.tab)
        }
        return .result()
    }
}

struct CaptureAuraTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Capture a Task"
    static let description = IntentDescription("Open Aura's quick capture with an optional task title.")
    static let openAppWhenRun = true

    @Parameter(
        title: "Task",
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var title: String?

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AuraIntentRouter.shared.pendingAction = .quickCapture(prefill: title ?? "")
        }
        return .result()
    }
}

struct AuraShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CaptureAuraTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Capture with \(.applicationName)"
            ],
            shortTitle: "Capture task",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: OpenAuraSectionIntent(),
            phrases: [
                "Open \(\.$destination) in \(.applicationName)"
            ],
            shortTitle: "Open Aura",
            systemImageName: "sparkles"
        )
    }
}
