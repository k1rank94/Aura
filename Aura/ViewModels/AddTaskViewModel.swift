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
        }
    }
    
    // Returns a TaskItem ONLY if it's a new task.
    // If it's an edit, it updates the existing model directly and returns nil.
    func save() -> TaskItem? {
        guard isValid else { return nil }
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingTask = taskToEdit {
            // SwiftData auto-saves these changes immediately!
            existingTask.title = cleanTitle
            existingTask.dueDate = dueDate
            existingTask.priority = priority
            existingTask.tag = tag
            return nil
        } else {
            // Return a brand new task
            return TaskItem(
                title: cleanTitle,
                isCompleted: false,
                dueDate: dueDate,
                priority: priority,
                tag: tag
            )
        }
    }
}
