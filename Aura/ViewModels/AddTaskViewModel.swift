//
//  AddTaskViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import Foundation
import SwiftData

@Observable
class AddTaskViewModel {
    var title: String = ""
    var dueDate: Date? = nil
    var priority: Priority = .low
    var tag: String? = nil
    
    // NEW: Add recurrence state
    var recurrence: RecurrenceRule? = nil
    
    // Support assigning to a list
    var list: TaskList? = nil

    // Hold onto the existing task if we are editing
    var taskToEdit: TaskItem?
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Custom initializer to pre-fill the data if a task is passed in
    init(task: TaskItem? = nil) {
        self.taskToEdit = task
        if let task = task {
            self.title = task.title
            self.dueDate = task.dueDate
            self.priority = task.priority
            self.tag = task.tag
            // NEW: Load existing recurrence rule if editing
            self.recurrence = task.recurrence
            self.list = task.list
        }
    }
    
    // Returns a TaskItem ONLY if it's a new task.
    // If it's an edit, it updates the existing model directly and returns nil.
    func save() -> TaskItem? {
        guard isValid else { return nil }
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingTask = taskToEdit {
            // SwiftData auto-saves property changes applied to active models.
            existingTask.title = cleanTitle
            existingTask.dueDate = dueDate
            existingTask.priority = priority
            existingTask.tag = tag
            // NEW: Update the recurrence rule
            existingTask.recurrence = recurrence
            existingTask.list = list
            return nil
        } else {
            // Generate and return a new task so the parent view can insert it into the context.
            return TaskItem(
                title: cleanTitle,
                isCompleted: false,
                dueDate: dueDate,
                priority: priority,
                tag: tag,
                recurrence: recurrence, // NEW: Inject the recurrence rule on creation
                list: list
            )
        }
    }
}
