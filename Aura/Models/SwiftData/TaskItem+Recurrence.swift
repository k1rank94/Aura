//
//  TaskItem+Recurrence.swift
//  Aura
//
//  Created by Kiran on 31/03/26.
//

import Foundation

extension TaskItem {
    
    /// Generates the next occurrence of a repeating task.
    ///
    /// - Returns: A brand new, incomplete `TaskItem` scheduled for the next valid date,
    ///   or `nil` if the task does not have a recurrence rule or a base due date.
    func generateNextOccurrence() -> TaskItem? {
        // 1. Ensure the task actually repeats and has a starting date
        guard let recurrenceRule = self.recurrence,
              let currentDueDate = self.dueDate else {
            return nil
        }
        
        // 2. Set up the exact calendar math required
        var dateComponent = DateComponents()
        switch recurrenceRule {
        case .daily:
            dateComponent.day = 1
        case .weekly:
            dateComponent.weekOfYear = 1
        case .monthly:
            dateComponent.month = 1
        }
        
        // 3. Calculate the new date using the user's local calendar
        guard let nextDate = Calendar.current.date(byAdding: dateComponent, to: currentDueDate) else {
            return nil
        }
        
        // 4. Return a pristine clone of the current task, but scheduled for the future
        return TaskItem(
            title: self.title,
            isCompleted: false,     // The new occurrence is always incomplete
            dueDate: nextDate,      // The newly calculated future date
            priority: self.priority,
            tag: self.tag,
            recurrence: self.recurrence, // Carry over the repeating rule!
            list: self.list // Carry over list
        )
    }
}
