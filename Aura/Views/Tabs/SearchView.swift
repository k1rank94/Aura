//
//  SearchView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SearchViewModel()
    
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    @State private var taskToEdit: TaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                headerSection
                searchBar
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
            
            List {
                let results = viewModel.filteredTasks(from: allTasks)
                
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView("Search", systemImage: "magnifyingglass", description: Text("Find tasks by title."))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.top, 40)
                    
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.top, 40)
                    
                } else {
                    ForEach(results) { task in
                        taskRow(for: task)
                    }
                }
                
                Spacer().frame(height: 100)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .sheet(item: $taskToEdit) { task in
                AddTaskSheet(task: task) { _ in
                    NotificationManager.shared.scheduleNotification(for: task)
                }
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(32)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    
    @ViewBuilder
    private func taskRow(for task: TaskItem) -> some View {
        TaskRowView(task: task) {
            let isBecomingCompleted = !task.isCompleted
            viewModel.toggleTaskCompletion(task)
            
            if isBecomingCompleted, let newTask = task.generateNextOccurrence() {
                context.insert(newTask)
                NotificationManager.shared.scheduleNotification(for: newTask)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        // DARK MODE FIX
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .onTapGesture {
            taskToEdit = task
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    NotificationManager.shared.cancelNotification(for: task.id)
                    context.delete(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FIND")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .kerning(1.2)
                
                Text("Search")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    // DARK MODE FIX
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.title3)
            
            TextField("What are you looking for?", text: $viewModel.searchText)
                .font(.body)
                .foregroundColor(.primary)
                .autocorrectionDisabled()
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    withAnimation {
                        viewModel.searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.title3)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        // DARK MODE FIX
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
