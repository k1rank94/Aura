//
//  TaskDetailView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskList.title) private var lists: [TaskList]

    let task: TaskItem

    @State private var newSubtaskTitle = ""
    @State private var isShowingSchedule = false
    @FocusState private var isAddingSubtask: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AuraAmbientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: AuraSpace.lg) {
                        completionHeader
                        titleAndNotes
                        metadata
                        subtasksSection
                        destructiveActions
                    }
                    .padding(.horizontal, AuraSpace.lg)
                    .padding(.top, AuraSpace.md)
                    .padding(.bottom, 80)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: dismiss.callAsFunction)
                        .fontWeight(.bold)
                }
            }
        }
        .tint(AuraColor.orchid)
    }

    private var completionHeader: some View {
        Button(action: toggleCompletion) {
            HStack(spacing: AuraSpace.md) {
                Image(systemName: task.isCompleted ? "checkmark.seal.fill" : "circle")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(task.isCompleted ? AuraColor.mint : AuraColor.orchid)

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.isCompleted ? "Completed" : "In progress")
                        .font(.headline)
                    Text(task.isCompleted ? "Tap to return this task to your plan" : "Tap when this feels complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(AuraSpace.md)
            .auraCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private var titleAndNotes: some View {
        VStack(alignment: .leading, spacing: AuraSpace.md) {
            TextField("Task title", text: Bindable(task).title, axis: .vertical)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .lineLimit(1...4)

            Divider().opacity(0.5)

            TextField("Notes, links, or context…", text: Bindable(task).notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...10)
        }
        .padding(AuraSpace.lg)
        .auraCard(elevated: true)
    }

    private var metadata: some View {
        VStack(spacing: AuraSpace.sm) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    if task.dueDate == nil {
                        task.dueDate = .now
                    }
                    isShowingSchedule.toggle()
                }
            } label: {
                TaskDetailRow(
                    icon: "calendar",
                    title: "Schedule",
                    value: task.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "Inbox",
                    color: AuraColor.orchid
                )
            }
            .buttonStyle(.plain)

            if isShowingSchedule {
                DatePicker(
                    "Due",
                    selection: Binding(
                        get: { task.dueDate ?? .now },
                        set: {
                            task.dueDate = $0
                            NotificationManager.shared.scheduleNotification(for: task)
                        }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding(AuraSpace.md)
                .auraCard()
                .transition(.move(edge: .top).combined(with: .opacity))

                Button("Remove schedule", role: .destructive) {
                    task.dueDate = nil
                    NotificationManager.shared.cancelNotification(for: task.id)
                    withAnimation { isShowingSchedule = false }
                }
                .font(.caption.weight(.semibold))
            }

            Menu {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Button(priorityLabel(priority)) { task.priority = priority }
                }
            } label: {
                TaskDetailRow(
                    icon: "flag.fill",
                    title: "Priority",
                    value: priorityLabel(task.priority),
                    color: priorityColor
                )
            }

            Menu {
                Button("Never") { task.recurrence = nil }
                ForEach(RecurrenceRule.allCases, id: \.self) { recurrence in
                    Button(recurrence.rawValue) { task.recurrence = recurrence }
                }
            } label: {
                TaskDetailRow(
                    icon: "repeat",
                    title: "Repeat",
                    value: task.recurrence?.rawValue ?? "Never",
                    color: AuraColor.violet
                )
            }

            Menu {
                Button("No estimate") { task.estimatedMinutes = nil }
                ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                    Button("\(minutes) minutes") { task.estimatedMinutes = minutes }
                }
            } label: {
                TaskDetailRow(
                    icon: "hourglass",
                    title: "Effort",
                    value: task.estimatedMinutes.map { "\($0) min" } ?? "None",
                    color: AuraColor.sun
                )
            }

            Menu {
                Button("Inbox") { task.list = nil }
                ForEach(lists) { list in
                    Button(list.title) { task.list = list }
                }
            } label: {
                TaskDetailRow(
                    icon: "list.bullet",
                    title: "List",
                    value: task.list?.title ?? "Inbox",
                    color: AuraColor.mint
                )
            }
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            AuraSectionHeading(
                "Subtasks",
                eyebrow: "Break it down",
                trailing: task.subtasks.isEmpty ? nil : "\(task.completedSubtaskCount)/\(task.subtasks.count)"
            )

            VStack(spacing: 0) {
                ForEach(task.sortedSubtasks) { subtask in
                    HStack(spacing: AuraSpace.md) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                subtask.isCompleted.toggle()
                            }
                            HapticManager.shared.selection()
                        } label: {
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(subtask.isCompleted ? AuraColor.mint : AuraColor.orchid)
                        }
                        .buttonStyle(.plain)

                        TextField("Subtask", text: Bindable(subtask).title)
                            .strikethrough(subtask.isCompleted)
                            .foregroundStyle(subtask.isCompleted ? .secondary : .primary)

                        Button(role: .destructive) {
                            context.delete(subtask)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption.bold())
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 13)

                    Divider().padding(.leading, 42)
                }

                HStack(spacing: AuraSpace.md) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AuraColor.auraGradient)

                    TextField("Add a small next step", text: $newSubtaskTitle)
                        .focused($isAddingSubtask)
                        .submitLabel(.done)
                        .onSubmit(addSubtask)

                    if !newSubtaskTitle.isEmpty {
                        Button("Add", action: addSubtask)
                            .font(.caption.bold())
                    }
                }
                .padding(.vertical, 13)
            }
            .padding(.horizontal, AuraSpace.md)
            .auraCard(cornerRadius: 20)
        }
    }

    private var destructiveActions: some View {
        Button(role: .destructive, action: deleteTask) {
            Label("Delete task", systemImage: "trash")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(AuraColor.coral)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: AuraColor.violet
        case .medium: AuraColor.sun
        case .high: AuraColor.coral
        }
    }

    @MainActor
    private func toggleCompletion() {
        let willComplete = !task.isCompleted
        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
            task.toggleCompletion()
        }
        HapticManager.shared.notification(type: willComplete ? .success : .warning)

        if willComplete, let next = task.generateNextOccurrence() {
            context.insert(next)
            NotificationManager.shared.scheduleNotification(for: next)
        }
    }

    private func addSubtask() {
        let title = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let nextOrder = (task.subtasks.map(\.sortOrder).max() ?? -1) + 1
        let subtask = TaskSubtask(title: title, sortOrder: nextOrder, task: task)
        context.insert(subtask)
        task.subtasks.append(subtask)
        newSubtaskTitle = ""
        HapticManager.shared.selection()
    }

    private func deleteTask() {
        NotificationManager.shared.cancelNotification(for: task.id)
        context.delete(task)
        HapticManager.shared.notification(type: .warning)
        dismiss()
    }

    private func priorityLabel(_ priority: Priority) -> String {
        switch priority {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
}

private struct TaskDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: AuraSpace.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(AuraSpace.md)
        .auraCard(cornerRadius: 18)
    }
}
