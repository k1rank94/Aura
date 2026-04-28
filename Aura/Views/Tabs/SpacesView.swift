//
//  SpacesView.swift
//  Aura
//
//  Created by Jules.
//

import SwiftUI
import SwiftData

struct SpacesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskSpace.createdAt, order: .forward) private var spaces: [TaskSpace]

    @State private var showingAddSpace = false
    @State private var newSpaceTitle = ""

    var body: some View {
        NavigationStack {
            List {
                headerSection
                    .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                ForEach(spaces) { space in
                    NavigationLink(destination: ListsView(space: space)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(space.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(space.lists.count) lists")
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
                                context.delete(space)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSpace = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Space", isPresented: $showingAddSpace) {
                TextField("Space Name", text: $newSpaceTitle)
                Button("Cancel", role: .cancel) { newSpaceTitle = "" }
                Button("Add") {
                    let space = TaskSpace(title: newSpaceTitle)
                    context.insert(space)
                    newSpaceTitle = ""
                }
            } message: {
                Text("Enter a name for the new space.")
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ORGANIZATION")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .kerning(1.2)

                Text("Spaces")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
}
