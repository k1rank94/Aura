//
//  AddTaskSheet.swift
//  Aura
//

import SwiftData
import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \TaskList.title) private var allLists: [TaskList]

    @State private var viewModel: AddTaskViewModel
    @State private var isShowingSchedule = false
    @FocusState private var focusedField: Field?

    let onSave: (TaskItem?) -> Void

    private enum Field {
        case title
        case notes
    }

    init(
        task: TaskItem? = nil,
        initialTitle: String = "",
        onSave: @escaping (TaskItem?) -> Void
    ) {
        _viewModel = State(initialValue: AddTaskViewModel(task: task, initialTitle: initialTitle))
        _isShowingSchedule = State(initialValue: task?.dueDate != nil)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuraAmbientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: AuraSpace.lg) {
                        titleEditor
                        notesEditor
                        quickSchedule

                        if isShowingSchedule {
                            scheduleEditor
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        metadataGrid
                    }
                    .padding(.horizontal, AuraSpace.lg)
                    .padding(.top, AuraSpace.md)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(viewModel.taskToEdit == nil ? "New task" : "Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.taskToEdit == nil ? "Create" : "Save", action: save)
                        .fontWeight(.bold)
                        .disabled(!viewModel.isValid)
                }
            }
        }
        .tint(AuraColor.orchid)
        .interactiveDismissDisabled(!viewModel.title.isEmpty || !viewModel.notes.isEmpty)
        .onAppear {
            focusedField = .title
        }
    }

    private var titleEditor: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            Text("What deserves your attention?")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuraColor.orchid)
                .textCase(.uppercase)
                .tracking(1.1)

            TextField("Name this task", text: $viewModel.title, axis: .vertical)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .lineLimit(1...3)
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit { focusedField = .notes }
        }
    }

    private var notesEditor: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            Label("Notes", systemImage: "text.alignleft")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Add context, links, or a tiny first step…", text: $viewModel.notes, axis: .vertical)
                .lineLimit(2...6)
                .focused($focusedField, equals: .notes)
                .padding(AuraSpace.md)
                .auraCard(cornerRadius: 18)
        }
    }

    private var quickSchedule: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            Text("When")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: AuraSpace.sm) {
                scheduleButton("Today", icon: "sun.max.fill", date: .now)
                scheduleButton("Tomorrow", icon: "sunrise.fill", date: tomorrow)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        if viewModel.dueDate == nil {
                            viewModel.dueDate = .now
                        }
                        isShowingSchedule.toggle()
                    }
                } label: {
                    Label("Pick", systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AuraPillButtonStyle(isSelected: isShowingSchedule))
            }

            if viewModel.dueDate != nil {
                Button(role: .destructive) {
                    withAnimation {
                        viewModel.dueDate = nil
                        isShowingSchedule = false
                    }
                } label: {
                    Label("Move to Inbox", systemImage: "tray")
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }

    private var scheduleEditor: some View {
        DatePicker(
            "Date and time",
            selection: Binding(
                get: { viewModel.dueDate ?? .now },
                set: { viewModel.dueDate = $0 }
            ),
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.graphical)
        .padding(AuraSpace.md)
        .auraCard()
    }

    private var metadataGrid: some View {
        VStack(spacing: AuraSpace.sm) {
            AuraMenuRow(
                icon: "flag.fill",
                title: "Priority",
                value: priorityTitle,
                tint: priorityColor
            ) {
                Picker("Priority", selection: $viewModel.priority) {
                    Text("Low").tag(Priority.low)
                    Text("Medium").tag(Priority.medium)
                    Text("High").tag(Priority.high)
                }
            }

            AuraMenuRow(
                icon: "repeat",
                title: "Repeat",
                value: viewModel.recurrence?.rawValue ?? "Never",
                tint: AuraColor.violet
            ) {
                Button("Never") { viewModel.recurrence = nil }
                ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                    Button(rule.rawValue) { viewModel.recurrence = rule }
                }
            }

            AuraMenuRow(
                icon: "hourglass",
                title: "Effort",
                value: effortTitle,
                tint: AuraColor.sun
            ) {
                Button("No estimate") { viewModel.estimatedMinutes = nil }
                ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                    Button(minutes < 60 ? "\(minutes) minutes" : "\(minutes / 60)h \(minutes % 60 == 0 ? "" : "30m")") {
                        viewModel.estimatedMinutes = minutes
                    }
                }
            }

            AuraMenuRow(
                icon: "list.bullet",
                title: "List",
                value: viewModel.list?.title ?? "Inbox",
                tint: AuraColor.mint
            ) {
                Button("Inbox") { viewModel.list = nil }
                ForEach(allLists) { list in
                    Button(list.title) { viewModel.list = list }
                }
            }
        }
    }

    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    }

    private var priorityTitle: String {
        switch viewModel.priority {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    private var priorityColor: Color {
        switch viewModel.priority {
        case .low: AuraColor.violet
        case .medium: AuraColor.sun
        case .high: AuraColor.coral
        }
    }

    private var effortTitle: String {
        guard let minutes = viewModel.estimatedMinutes else { return "None" }
        return minutes < 60 ? "\(minutes) min" : "\(minutes / 60) hr"
    }

    private func scheduleButton(_ title: String, icon: String, date: Date) -> some View {
        let selected = viewModel.dueDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false

        return Button {
            let currentTime = viewModel.dueDate ?? date
            let time = Calendar.current.dateComponents([.hour, .minute], from: currentTime)
            viewModel.dueDate = Calendar.current.date(
                bySettingHour: time.hour ?? 9,
                minute: time.minute ?? 0,
                second: 0,
                of: date
            )
            isShowingSchedule = false
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AuraPillButtonStyle(isSelected: selected))
    }

    private func save() {
        onSave(viewModel.save())
        dismiss()
    }
}

private struct AuraMenuRow<MenuContent: View>: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color
    @ViewBuilder let menuContent: () -> MenuContent

    var body: some View {
        Menu {
            menuContent()
        } label: {
            HStack(spacing: AuraSpace.md) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))

                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(AuraSpace.md)
            .auraCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

private struct AuraPillButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.bold))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                isSelected ? AnyShapeStyle(AuraColor.auraGradient) : AnyShapeStyle(.thinMaterial),
                in: Capsule()
            )
            .overlay(Capsule().stroke(.white.opacity(isSelected ? 0.25 : 0.5), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
