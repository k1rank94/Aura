//
//  ListsView.swift
//  Aura
//
//  Created by Jules.
//

import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(\.modelContext) private var context
    var space: TaskSpace

    @State private var showingAddList = false
    @State private var newListTitle = ""

    var body: some View {
        List {
            ForEach(space.lists.sorted(by: { $0.createdAt < $1.createdAt })) { list in
                NavigationLink(destination: TasksListView(list: list)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(list.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(list.tasks.count) tasks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            context.delete(list)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(space.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddList = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New List", isPresented: $showingAddList) {
            TextField("List Name", text: $newListTitle)
            Button("Cancel", role: .cancel) { newListTitle = "" }
            Button("Add") {
                let list = TaskList(title: newListTitle, space: space)
                context.insert(list)
                newListTitle = ""
            }
        } message: {
            Text("Enter a name for the new list.")
        }
    }
}
