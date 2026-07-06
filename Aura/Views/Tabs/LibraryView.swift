//
//  LibraryView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(AuraRouter.self) private var router
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @Query(sort: \TaskSpace.createdAt) private var spaces: [TaskSpace]

    @State private var searchText = ""

    private var inboxTasks: [TaskItem] {
        tasks.filter { $0.dueDate == nil && !$0.isCompleted }
    }

    private var completedTasks: [TaskItem] {
        tasks.filter(\.isCompleted)
    }

    private var searchResults: [TaskItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.notes.localizedCaseInsensitiveContains(searchText)
                || ($0.tag?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.lg) {
                    LibraryHeader(onSettings: { router.presentedSheet = .settings })
                    searchField

                    if searchText.isEmpty {
                        overview
                        spacesSection
                        inboxSection
                        completedSection
                    } else {
                        resultsSection
                    }
                }
                .padding(.horizontal, AuraSpace.lg)
                .padding(.top, AuraSpace.md)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var searchField: some View {
        HStack(spacing: AuraSpace.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AuraColor.orchid)

            TextField("Search tasks and notes", text: $searchText)
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, AuraSpace.md)
        .frame(height: 52)
        .auraCard(cornerRadius: 18)
    }

    private var overview: some View {
        HStack(spacing: AuraSpace.sm) {
            LibraryMetric(
                value: "\(inboxTasks.count)",
                label: "Inbox",
                icon: "tray.fill",
                color: AuraColor.violet
            )
            LibraryMetric(
                value: "\(spaces.count)",
                label: "Spaces",
                icon: "square.stack.3d.up.fill",
                color: AuraColor.mint
            )
            LibraryMetric(
                value: "\(completedTasks.count)",
                label: "Done",
                icon: "checkmark.seal.fill",
                color: AuraColor.coral
            )
        }
    }

    @ViewBuilder
    private var spacesSection: some View {
        VStack(spacing: AuraSpace.sm) {
            AuraSectionHeading("Spaces", eyebrow: "Organize", trailing: "\(spaces.count)")

            if spaces.isEmpty {
                NavigationLink {
                    SpacesView()
                } label: {
                    LibraryNavigationRow(
                        icon: "square.stack.3d.up",
                        color: AuraColor.mint,
                        title: "Create your first space",
                        subtitle: "Group lists around work, life, or a goal"
                    )
                }
                .buttonStyle(.plain)
            } else {
                ForEach(spaces) { space in
                    NavigationLink {
                        ListsView(space: space)
                    } label: {
                        LibraryNavigationRow(
                            icon: "folder.fill",
                            color: AuraColor.mint,
                            title: space.title,
                            subtitle: "\(space.lists.count) \(space.lists.count == 1 ? "list" : "lists")"
                        )
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink {
                    SpacesView()
                } label: {
                    Label("Manage spaces", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AuraColor.orchid)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AuraSpace.xs)
                }
            }
        }
    }

    @ViewBuilder
    private var inboxSection: some View {
        VStack(spacing: AuraSpace.sm) {
            AuraSectionHeading("Inbox", eyebrow: "Unscheduled", trailing: "\(inboxTasks.count)")

            if inboxTasks.isEmpty {
                LibraryNavigationRow(
                    icon: "tray",
                    color: AuraColor.violet,
                    title: "Inbox zero",
                    subtitle: "Unscheduled captures will wait here"
                )
            } else {
                ForEach(inboxTasks.prefix(4)) { task in
                    AuraTaskRow(task: task) {
                        router.edit(task)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var completedSection: some View {
        if !completedTasks.isEmpty {
            VStack(spacing: AuraSpace.sm) {
                AuraSectionHeading("Recently completed", eyebrow: "History", trailing: "\(completedTasks.count)")

                ForEach(completedTasks.prefix(3)) { task in
                    AuraTaskRow(task: task) {
                        router.edit(task)
                    }
                }
            }
            .opacity(0.74)
        }
    }

    private var resultsSection: some View {
        VStack(spacing: AuraSpace.sm) {
            AuraSectionHeading("Results", eyebrow: "Search", trailing: "\(searchResults.count)")

            if searchResults.isEmpty {
                AuraEmptyState(
                    icon: "magnifyingglass",
                    title: "Nothing found",
                    message: "Try a task title, note, or tag."
                )
            } else {
                ForEach(searchResults) { task in
                    AuraTaskRow(task: task) {
                        router.edit(task)
                    }
                }
            }
        }
    }
}

private struct LibraryHeader: View {
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("EVERYTHING, IN ITS PLACE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AuraColor.mint)
                    .tracking(1.1)
                Text("Library")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                Text("Find, organize, and look back.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AuraColor.auraGradient)
                    .frame(width: 44, height: 44)
                    .background(.thinMaterial, in: Circle())
            }
            .accessibilityLabel("Open settings")
        }
    }
}

private struct LibraryMetric: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.black))
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AuraSpace.md)
        .auraCard(cornerRadius: 20)
        .accessibilityElement(children: .combine)
    }
}

private struct LibraryNavigationRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: AuraSpace.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
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
