//
//  AddTaskSheet.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTaskViewModel
    
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskList.title, order: .forward) private var allLists: [TaskList]

    @State private var showingCustomTagAlert = false
    @State private var customTagText = ""
    
    var onSave: (TaskItem?) -> Void
    let availableTags = ["Work", "Personal", "Health", "Urgent"]
    
    init(task: TaskItem? = nil, onSave: @escaping (TaskItem?) -> Void) {
        self._viewModel = State(initialValue: AddTaskViewModel(task: task))
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            ZStack {
                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.4))
                            .font(.title2)
                    }
                }
            }
            .padding(.top, 12)
            
            TextField("What needs to be done?", text: $viewModel.title)
                .font(.system(size: 24, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .submitLabel(.done)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    datePickerPill
                    
                    Menu {
                        Button("None") { viewModel.recurrence = nil }
                        
                        Divider()
                        
                        ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                            Button(rule.rawValue) { viewModel.recurrence = rule }
                        }
                    } label: {
                        actionPill(
                            icon: "repeat",
                            title: viewModel.recurrence?.rawValue ?? "Repeat",
                            isActive: viewModel.recurrence != nil
                        )
                    }
                    
                    Menu {
                        Button("Inbox (No List)") { viewModel.list = nil }

                        Divider()

                        ForEach(allLists) { list in
                            Button(list.title) { viewModel.list = list }
                        }
                    } label: {
                        actionPill(
                            icon: "list.bullet",
                            title: viewModel.list?.title ?? "List",
                            isActive: viewModel.list != nil
                        )
                    }

                    Menu {
                        ForEach(availableTags, id: \.self) { tag in
                            Button(tag) { viewModel.tag = tag }
                        }
                        
                        Divider()
                        
                        Button("Custom Tag...") {
                            showingCustomTagAlert = true
                        }
                        
                        if viewModel.tag != nil {
                            Button("Clear Tag", role: .destructive) { viewModel.tag = nil }
                        }
                    } label: {
                        actionPill(
                            icon: "tag",
                            title: viewModel.tag ?? "Add Tag",
                            isActive: viewModel.tag != nil
                        )
                    }
                    
                    Menu {
                        Picker("Priority", selection: $viewModel.priority) {
                            Text("Low").tag(Priority.low)
                            Text("Medium").tag(Priority.medium)
                            Text("High").tag(Priority.high)
                        }
                    } label: {
                        actionPill(
                            icon: "flag",
                            title: priorityString(for: viewModel.priority),
                            isActive: viewModel.priority != .low,
                            dotColor: priorityColor(for: viewModel.priority)
                        )
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                let newTaskOrNil = viewModel.save()
                onSave(newTaskOrNil)
                dismiss()
            }) {
                Text(viewModel.taskToEdit == nil ? "Save Task" : "Update Task")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isValid ? Color.pink : Color.pink.opacity(0.5))
                    .cornerRadius(16)
            }
            .disabled(!viewModel.isValid)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .interactiveDismissDisabled(!viewModel.title.isEmpty)
        // DARK MODE FIX: Use systemBackground instead of hardcoded white
        .presentationBackground(Color(UIColor.systemBackground))
        
        .alert("New Tag", isPresented: $showingCustomTagAlert) {
            TextField("e.g. Finance, Groceries", text: $customTagText)
            
            Button("Add") {
                let trimmed = customTagText.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    viewModel.tag = trimmed
                }
                customTagText = ""
            }
            
            Button("Cancel", role: .cancel) {
                customTagText = ""
            }
        }
    }
    
    private var datePickerPill: some View {
        ZStack {
            if let date = viewModel.dueDate {
                DatePicker("", selection: Binding(
                    get: { date },
                    set: { viewModel.dueDate = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .tint(.pink)
            } else {
                Button(action: {
                    viewModel.dueDate = Date()
                }) {
                    actionPill(icon: "calendar", title: "Set Date", isActive: false)
                }
            }
        }
    }
    
    private func actionPill(icon: String, title: String, isActive: Bool, dotColor: Color? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            if let dotColor = dotColor {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
            }
        }
        // DARK MODE FIX: Adaptive unselected text color instead of hardcoded dark grey
        .foregroundColor(isActive ? .pink : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.pink.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                .background(isActive ? Color.pink.opacity(0.05) : Color.clear)
        )
    }
    
    private func priorityString(for priority: Priority) -> String {
        switch priority {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .red
        }
    }
}
