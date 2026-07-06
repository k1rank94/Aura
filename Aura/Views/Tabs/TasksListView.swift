//
//  TasksListView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct TasksListView: View {
    @Environment(\.modelContext) private var context
    @Environment(AuraRouter.self) private var router

    let list: TaskList

    @State private var isAddingTask = false

    private var tasks: [TaskItem] {
        list.tasks.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            return $0.createdAt < $1.createdAt
        }
    }

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.sm) {
                    AuraSectionHeading(
                        list.title,
                        eyebrow: list.space?.title,
                        trailing: "\(tasks.filter { !$0.isCompleted }.count) open"
                    )

                    if tasks.isEmpty {
                        AuraEmptyState(
                            icon: "list.bullet.clipboard",
                            title: "Nothing here yet",
                            message: "Capture the first task for this list."
                        )
                    } else {
                        ForEach(tasks) { task in
                            AuraTaskRow(task: task) {
                                router.edit(task)
                            }
                        }
                    }
                }
                .padding(AuraSpace.lg)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .tint(AuraColor.orchid)
        .sheet(isPresented: $isAddingTask) {
            AddTaskSheet { newTask in
                guard let newTask else { return }
                newTask.list = list
                context.insert(newTask)
                NotificationManager.shared.scheduleNotification(for: newTask)
                HapticManager.shared.notification(type: .success)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
    }
}
