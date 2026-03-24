//
//  AddTaskSheet.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI

/// A dynamic modal sheet used for both creating new tasks and editing existing ones.
///
/// `AddTaskSheet` relies on `AddTaskViewModel` to manage its internal form state.
/// It provides interactive pills for selecting dates, tags, and priority levels.
struct AddTaskSheet: View {
    
    /// The environment value allowing the view to dismiss itself.
    @Environment(\.dismiss) private var dismiss
    
    /// The state-driven view model handling the form's logic and validation.
    @State private var viewModel: AddTaskViewModel
    
    // State for managing custom tag input
    @State private var showingCustomTagAlert = false
    @State private var customTagText = ""
    
    /// A closure executed upon a successful save.
    /// Returns a new `TaskItem` if one was created, or `nil` if an existing task was updated.
    var onSave: (TaskItem?) -> Void
    
    /// A predefined list of common tags for quick selection.
    let availableTags = ["Work", "Personal", "Health", "Urgent"]
    
    /// Custom initializer accommodating both new task creation and existing task editing.
    ///
    /// - Parameters:
    ///   - task: The optional `TaskItem` to edit.
    ///   - onSave: The completion handler fired when the user successfully saves.
    init(task: TaskItem? = nil, onSave: @escaping (TaskItem?) -> Void) {
        self._viewModel = State(initialValue: AddTaskViewModel(task: task))
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Modal Header & Drag Handle
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
            
            // Primary Title Input
            TextField("What needs to be done?", text: $viewModel.title)
                .font(.system(size: 24, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .submitLabel(.done)
            
            // Interactive Metadata Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    // Date & Time Configuration
                    datePickerPill
                    
                    // Categorization Tag Menu
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
                    
                    // Priority Level Configuration
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
            
            // Context-Aware Save/Update Button
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
        // Prevent accidental dismissal if the user has started typing
        .interactiveDismissDisabled(!viewModel.title.isEmpty)
        .presentationBackground(.white)
        
        // Custom Tag Input Alert
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
    
    // MARK: - Interactive UI Helpers
    
    /// A custom date picker encapsulated in a stylized pill format.
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
    
    /// A reusable building block for creating interactive settings pills.
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
        .foregroundColor(isActive ? .pink : Color(red: 0.2, green: 0.2, blue: 0.3))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.pink.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                .background(isActive ? Color.pink.opacity(0.05) : Color.clear)
        )
    }
    
    /// Converts a `Priority` enum to a localized string representation.
    private func priorityString(for priority: Priority) -> String {
        switch priority {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    /// Maps a `Priority` enum to a corresponding thematic color.
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

#Preview {
    AddTaskSheet(onSave: { _ in })
}

