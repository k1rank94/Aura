//
//  SearchViewModel.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import Foundation
import SwiftData

@Observable
class SearchViewModel {
    var searchText: String = ""
    
    // Filters the database array based on the user's input
    func filteredTasks(from tasks: [TaskItem]) -> [TaskItem] {
        // If the search bar is empty, return nothing
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        
        // Otherwise, return tasks that contain the search text (case-insensitive)
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
    }
}