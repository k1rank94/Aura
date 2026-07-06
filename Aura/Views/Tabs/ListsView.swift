//
//  ListsView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct ListsView: View {
    @Environment(\.modelContext) private var context
    let space: TaskSpace

    @State private var isAddingList = false
    @State private var newListTitle = ""

    private var lists: [TaskList] {
        space.lists.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.sm) {
                    AuraSectionHeading(space.title, eyebrow: "Space", trailing: "\(lists.count) lists")

                    if lists.isEmpty {
                        AuraEmptyState(
                            icon: "list.bullet.rectangle",
                            title: "A fresh space",
                            message: "Add a list for a project, routine, or part of your life."
                        )
                    } else {
                        ForEach(lists) { list in
                            NavigationLink {
                                TasksListView(list: list)
                            } label: {
                                ListRow(list: list)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    context.delete(list)
                                }
                            }
                        }
                    }
                }
                .padding(AuraSpace.lg)
            }
        }
        .navigationTitle(space.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingList = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .tint(AuraColor.orchid)
        .alert("New list", isPresented: $isAddingList) {
            TextField("List name", text: $newListTitle)
            Button("Cancel", role: .cancel) { newListTitle = "" }
            Button("Create", action: createList)
                .disabled(newListTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func createList() {
        let title = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let list = TaskList(title: title, space: space)
        context.insert(list)
        space.lists.append(list)
        newListTitle = ""
        HapticManager.shared.notification(type: .success)
    }
}

private struct ListRow: View {
    let list: TaskList

    var body: some View {
        HStack(spacing: AuraSpace.md) {
            Image(systemName: "list.bullet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AuraColor.violet)
                .frame(width: 48, height: 48)
                .background(AuraColor.violet.opacity(0.11), in: RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(list.tasks.filter { !$0.isCompleted }.count) open · \(list.tasks.filter(\.isCompleted).count) done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(AuraSpace.md)
        .auraCard(cornerRadius: 20)
    }
}
