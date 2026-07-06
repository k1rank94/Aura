//
//  PlanView.swift
//  Aura
//

import SwiftData
import SwiftUI

struct PlanView: View {
    @Environment(AuraRouter.self) private var router
    @Query(
        filter: #Predicate<TaskItem> { $0.dueDate != nil },
        sort: \TaskItem.dueDate
    ) private var scheduledTasks: [TaskItem]

    @State private var selectedDate = Calendar.current.startOfDay(for: .now)

    private var dates: [Date] {
        let start = Calendar.current.startOfDay(for: .now)
        return (0..<14).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: start)
        }
    }

    private var selectedTasks: [TaskItem] {
        scheduledTasks.filter {
            guard let dueDate = $0.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                LazyVStack(spacing: AuraSpace.lg) {
                    PlanHeader()
                    dateRail
                    daySummary

                    if selectedTasks.isEmpty {
                        AuraEmptyState(
                            icon: "calendar.badge.checkmark",
                            title: "Space to breathe",
                            message: "Nothing is scheduled for this day."
                        )
                    } else {
                        VStack(spacing: AuraSpace.sm) {
                            AuraSectionHeading(
                                Calendar.current.isDateInToday(selectedDate) ? "Today" : "Schedule",
                                eyebrow: selectedDate.formatted(.dateTime.month(.wide).day()),
                                trailing: "\(selectedTasks.filter { !$0.isCompleted }.count) open"
                            )

                            ForEach(selectedTasks) { task in
                                AuraTaskRow(task: task) {
                                    router.edit(task)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AuraSpace.lg)
                .padding(.top, AuraSpace.md)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var dateRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AuraSpace.sm) {
                ForEach(dates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                        HapticManager.shared.selection()
                    } label: {
                        VStack(spacing: 7) {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                                .font(.caption2.bold())
                                .textCase(.uppercase)

                            Text(date.formatted(.dateTime.day()))
                                .font(.title3.weight(.black))

                            Circle()
                                .fill(hasOpenTasks(on: date) ? (isSelected ? .white : AuraColor.orchid) : .clear)
                                .frame(width: 4, height: 4)
                        }
                        .foregroundStyle(isSelected ? .white : .primary)
                        .frame(width: 48, height: 78)
                        .background(
                            isSelected ? AnyShapeStyle(AuraColor.auraGradient) : AnyShapeStyle(.thinMaterial),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(isSelected ? 0.25 : 0.55), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
                }
            }
        }
    }

    private var daySummary: some View {
        HStack(spacing: AuraSpace.md) {
            Image(systemName: "wand.and.stars")
                .font(.title2)
                .foregroundStyle(AuraColor.auraGradient)
                .frame(width: 48, height: 48)
                .background(AuraColor.violet.opacity(0.10), in: RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 3) {
                Text(loadMessage)
                    .font(.headline)
                Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(AuraSpace.md)
        .auraCard()
    }

    private var loadMessage: String {
        let openCount = selectedTasks.filter { !$0.isCompleted }.count
        return switch openCount {
        case 0: "A clear day"
        case 1...3: "A gentle rhythm"
        case 4...6: "A focused day"
        default: "A full day — protect your energy"
        }
    }

    private func hasOpenTasks(on date: Date) -> Bool {
        scheduledTasks.contains {
            guard let dueDate = $0.dueDate else { return false }
            return !$0.isCompleted && Calendar.current.isDate(dueDate, inSameDayAs: date)
        }
    }
}

private struct PlanHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("THE NEXT TWO WEEKS")
                .font(.caption.weight(.bold))
                .foregroundStyle(AuraColor.violet)
                .tracking(1.15)

            Text("Plan")
                .font(.system(size: 36, weight: .black, design: .rounded))

            Text("Shape your time before it shapes you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
