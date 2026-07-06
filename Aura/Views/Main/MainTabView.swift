//
//  MainTabView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI
import SwiftData

/// The primary container view presented after onboarding.
///
/// `MainTabView` orchestrates the core navigational structure of the application. It hosts
/// five distinct sub-views (Inbox, Today, Upcoming, Search, and Settings) while providing a persistent,
/// global Floating Action Button (FAB) that allows users to create new tasks from any context.
struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TaskItem]
    @State private var router = AuraRouter()
    @State private var intentRouter = AuraIntentRouter.shared
    @State private var quickCapturePrefill = ""
    @AppStorage("lastLaunchedVersion") private var lastLaunchedVersion: String = ""
    @State private var isShowingWhatsNew = false
    private let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    @AppStorage("isMorningBriefingEnabled") private var isMorningBriefingEnabled = false
    @AppStorage("isEveningBriefingEnabled") private var isEveningBriefingEnabled = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AuraAmbientBackground()

            TabView(selection: $router.selectedTab) {
                NavigationStack {
                    TodayView()
                }
                    .tabItem {
                        Label(AuraTab.today.title, systemImage: AuraTab.today.symbol)
                    }
                    .tag(AuraTab.today)

                NavigationStack {
                    PlanView()
                }
                    .tabItem {
                        Label(AuraTab.plan.title, systemImage: AuraTab.plan.symbol)
                    }
                    .tag(AuraTab.plan)

                NavigationStack {
                    LibraryView()
                }
                    .tabItem {
                        Label(AuraTab.library.title, systemImage: AuraTab.library.symbol)
                    }
                    .tag(AuraTab.library)
            }
            .tint(AuraColor.orchid)

            Button(action: showQuickCapture) {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 58, height: 58)
                    .background(AuraColor.auraGradient, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: AuraColor.orchid.opacity(0.38), radius: 18, y: 9)
            }
            .accessibilityLabel("Create a task")
            .padding(.trailing, AuraSpace.lg)
            .padding(.bottom, 76)
        }
        .onAppear {
            NotificationManager.shared.updateMorningBriefing(isEnabled: isMorningBriefingEnabled)
            NotificationManager.shared.updateEveningBriefing(isEnabled: isEveningBriefingEnabled)

            if lastLaunchedVersion != currentAppVersion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowingWhatsNew = true
                }
            }

            handleIntent()
            AuraWidgetSnapshotStore.save(tasks: allTasks)
        }
        .onChange(of: widgetFingerprint) { _, _ in
            AuraWidgetSnapshotStore.save(tasks: allTasks)
        }
        .onChange(of: intentRouter.pendingAction) { _, _ in
            handleIntent()
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetContent(for: sheet)
        }
        .sheet(isPresented: $isShowingWhatsNew, onDismiss: {
            lastLaunchedVersion = currentAppVersion
        }) {
            WhatsNewView(items: [
                WhatsNewItem(icon: "sparkles", title: "Luminous Calm", description: "A completely reimagined experience built around focus, clarity, and beautiful motion.", color: AuraColor.orchid),
                WhatsNewItem(icon: "calendar", title: "Plan Your Week", description: "Move naturally from today's focus into a thoughtful weekly plan.", color: AuraColor.violet),
                WhatsNewItem(icon: "checklist", title: "Richer Tasks", description: "Add notes, effort estimates, subtasks, priorities, and recurring schedules.", color: AuraColor.mint)
            ])
        }
        .environment(router)
    }

    @ViewBuilder
    private func sheetContent(for sheet: AuraSheet) -> some View {
        switch sheet {
        case .quickCapture:
            AddTaskSheet(task: nil, initialTitle: quickCapturePrefill) { newTask in
                guard let newTask else { return }
                context.insert(newTask)
                NotificationManager.shared.scheduleNotification(for: newTask)
                HapticManager.shared.notification(type: .success)
                quickCapturePrefill = ""
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)

        case .editTask(let task):
            TaskDetailView(task: task)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)

        case .settings:
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
    }

    private func showQuickCapture() {
        HapticManager.shared.impact(style: .light)
        router.showQuickCapture()
    }

    private func handleIntent() {
        guard let action = intentRouter.pendingAction else { return }
        switch action {
        case .open(let tab):
            router.selectedTab = tab
        case .quickCapture(let prefill):
            quickCapturePrefill = prefill
            router.showQuickCapture()
        }
        intentRouter.pendingAction = nil
    }

    private var widgetFingerprint: String {
        allTasks
            .map {
                "\($0.id.uuidString):\($0.isCompleted):\($0.dueDate?.timeIntervalSince1970 ?? 0):\($0.title)"
            }
            .joined(separator: "|")
    }
}

#Preview {
    MainTabView()
}
