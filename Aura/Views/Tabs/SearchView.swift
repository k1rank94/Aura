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
    
    // Fetch all tasks, newest first
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    
    // 1. State for Editing
    @State private var taskToEdit: TaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Fixed Header & Search Bar
            VStack(spacing: 16) {
                headerSection
                searchBar
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
            
            // Scrolling Results List
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
            
            // 2. The Edit Sheet
            .sheet(item: $taskToEdit) { task in
                AddTaskSheet(task: task) { _ in
                    // Reschedule in case they updated the due date or time
                    NotificationManager.shared.scheduleNotification(for: task)
                }
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(32)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    
    // MARK: - Subviews
    
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
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
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
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func taskRow(for task: TaskItem) -> some View {
        TaskRowView(task: task) {
            viewModel.toggleTaskCompletion(task)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        
        // 3. The Tap Gesture
        .onTapGesture {
            taskToEdit = task
        }
        
        // Swipe to Delete
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
}
// MARK: - Previews

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)
    
    return SearchView()
        .modelContainer(container)
}

#Preview("Populated Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)
    
    // Insert mock data for searching
    let sampleTasks = [
        TaskItem(title: "Buy Groceries", isCompleted: false, priority: .high),
        TaskItem(title: "Walk the Dog", isCompleted: true, priority: .medium),
        TaskItem(title: "Read a Book", isCompleted: false, priority: .low),
        TaskItem(title: "Schedule Dentist Appointment", isCompleted: false, priority: .medium)
    ]
    
    for task in sampleTasks {
        container.mainContext.insert(task)
    }
    
    return SearchView()
        .modelContainer(container)
}

#Preview("Dark Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TaskItem.self, configurations: config)
    
    let sampleTasks = [
        TaskItem(title: "Design Landing Page", isCompleted: false, priority: .high),
        TaskItem(title: "Review Pull Requests", isCompleted: true, priority: .low)
    ]
    
    for task in sampleTasks {
        container.mainContext.insert(task)
    }
    
    return SearchView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

