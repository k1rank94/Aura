//
//  SpacesView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct SpacesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskSpace.createdAt) private var spaces: [TaskSpace]

    @State private var isAddingSpace = false
    @State private var newSpaceTitle = ""

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.sm) {
                    AuraSectionHeading("Spaces", eyebrow: "Life, organized", trailing: "\(spaces.count)")

                    if spaces.isEmpty {
                        AuraEmptyState(
                            icon: "square.stack.3d.up",
                            title: "Create some breathing room",
                            message: "Spaces keep work, personal life, and bigger goals separate."
                        )
                    } else {
                        ForEach(spaces) { space in
                            NavigationLink {
                                ListsView(space: space)
                            } label: {
                                SpaceRow(space: space)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    context.delete(space)
                                }
                            }
                        }
                    }
                }
                .padding(AuraSpace.lg)
            }
        }
        .navigationTitle("Spaces")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingSpace = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .tint(AuraColor.orchid)
        .alert("New space", isPresented: $isAddingSpace) {
            TextField("Work, Personal, Launch…", text: $newSpaceTitle)
            Button("Cancel", role: .cancel) { newSpaceTitle = "" }
            Button("Create", action: createSpace)
                .disabled(newSpaceTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("A space can contain several focused lists.")
        }
    }

    private func createSpace() {
        let title = newSpaceTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        context.insert(TaskSpace(title: title))
        newSpaceTitle = ""
        HapticManager.shared.notification(type: .success)
    }
}

private struct SpaceRow: View {
    let space: TaskSpace

    private var openTaskCount: Int {
        space.lists.flatMap(\.tasks).filter { !$0.isCompleted }.count
    }

    var body: some View {
        HStack(spacing: AuraSpace.md) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.title3)
                .foregroundStyle(AuraColor.calmGradient)
                .frame(width: 50, height: 50)
                .background(AuraColor.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(space.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(space.lists.count) lists · \(openTaskCount) open")
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
