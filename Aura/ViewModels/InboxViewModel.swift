//
//  InboxViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import SwiftData

@Observable
class InboxViewModel {
    
    // Calculate progress for unscheduled tasks
    func calculateProgress(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
    
    func pendingCount(for tasks: [TaskItem]) -> Int {
        return tasks.filter { !$0.isCompleted }.count
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
    }
}