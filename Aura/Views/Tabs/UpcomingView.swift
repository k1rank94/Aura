//
//  UpcomingView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import SwiftUI
import SwiftData

struct UpcomingView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = UpcomingViewModel()
    
    @Query(
        filter: #Predicate<TaskItem> { $0.dueDate != nil },
        sort: \TaskItem.dueDate,
        order: .forward
    ) private var scheduledTasks: [TaskItem]
    
    // 1. State for Editing
    @State private var taskToEdit: TaskItem?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Pinned Headers
            headerSection
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(Color(UIColor.systemGroupedBackground))
            
            calendarScroller
                .padding(.bottom, 16)
                .background(Color(UIColor.systemGroupedBackground))
            
            // Scrolling List
            List {
                let filteredTasks = viewModel.tasksForSelectedDate(from: scheduledTasks)
                
                ForEach(filteredTasks) { task in
                    taskRow(for: task)
                }
                
                if filteredTasks.isEmpty {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                Spacer().frame(height: 100)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollIndicators(.hidden)
            
            // 2. The Edit Sheet
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
    
    // MARK: - Subviews
    
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
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SCHEDULED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .kerning(1.2)
                
                Text("Upcoming")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var calendarScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.upcomingDates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedDate = date
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(viewModel.dayOfWeek(for: date))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? .white : .gray)
                            
                            Text(viewModel.dayOfMonth(for: date))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? .white : Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(isSelected ? Color.pink : Color.white)
                        .cornerRadius(16)
                        .shadow(color: isSelected ? Color.pink.opacity(0.3) : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 60)
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
                .padding(.bottom, 8)
            Text("No tasks scheduled.")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Enjoy your free time!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}
