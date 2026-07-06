//
//  TodayView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(AuraRouter.self) private var router
    @Query(sort: \TaskItem.createdAt) private var allTasks: [TaskItem]

    private var todayTasks: [TaskItem] {
        allTasks
            .filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
            .sorted(by: taskSort)
    }

    private var overdueTasks: [TaskItem] {
        allTasks.filter(\.isOverdue).sorted(by: taskSort)
    }

    private var openTasks: [TaskItem] {
        todayTasks.filter { !$0.isCompleted }
    }

    private var completedTasks: [TaskItem] {
        todayTasks.filter(\.isCompleted)
    }

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.lg) {
                    TodayHeader(onSettings: { router.presentedSheet = .settings })

                    AuraProgressHero(
                        completed: completedTasks.count,
                        total: todayTasks.count
                    )

                    if !overdueTasks.isEmpty {
                        AuraTaskSection(
                            title: "Needs attention",
                            eyebrow: "Overdue",
                            tasks: overdueTasks,
                            onOpen: router.edit
                        )
                    }

                    if !openTasks.isEmpty {
                        AuraTaskSection(
                            title: "Your focus",
                            eyebrow: "Today",
                            tasks: openTasks,
                            onOpen: router.edit
                        )
                    }

                    if todayTasks.isEmpty && overdueTasks.isEmpty {
                        AuraEmptyState(
                            icon: "sparkles",
                            title: "A quiet day",
                            message: "Keep the space, or capture one meaningful thing for today."
                        )
                    }

                    if !completedTasks.isEmpty {
                        AuraTaskSection(
                            title: "Accomplished",
                            eyebrow: nil,
                            tasks: completedTasks,
                            onOpen: router.edit
                        )
                        .opacity(0.72)
                    }
                }
                .padding(.horizontal, AuraSpace.lg)
                .padding(.top, AuraSpace.sm)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func taskSort(_ lhs: TaskItem, _ rhs: TaskItem) -> Bool {
        if lhs.isCompleted != rhs.isCompleted {
            return !lhs.isCompleted
        }
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return (lhs.dueDate ?? lhs.createdAt) < (rhs.dueDate ?? rhs.createdAt)
    }
}

private struct TodayHeader: View {
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AuraColor.orchid)
                    .textCase(.uppercase)
                    .tracking(1.15)

                Text(greeting)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Make room for what matters.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onSettings) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(AuraColor.auraGradient)
                    .frame(width: 46, height: 46)
                    .background(.thinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1))
            }
            .accessibilityLabel("Open settings")
        }
        .padding(.top, AuraSpace.md)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        return switch hour {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }
}

private struct AuraTaskSection: View {
    let title: String
    let eyebrow: String?
    let tasks: [TaskItem]
    let onOpen: (TaskItem) -> Void

    var body: some View {
        VStack(spacing: AuraSpace.sm) {
            AuraSectionHeading(title, eyebrow: eyebrow, trailing: "\(tasks.count)")

            ForEach(tasks) { task in
                AuraTaskRow(task: task) {
                    onOpen(task)
                }
            }
        }
    }
}
