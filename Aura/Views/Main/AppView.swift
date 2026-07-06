//
//  ContentView.swift
//  Aura
//
//  Created by Kiran on 27/02/26.
//

import SwiftUI
import SwiftData

/// The root view of the Aura application.
///
/// `AppView` acts as the primary coordinator for the application's user interface.
/// It observes the global `AppState` to determine whether to show the initial onboarding
/// flow or the main tabbed interface. Additionally, it configures the global SwiftData
/// environment and requests necessary system permissions on launch.
struct AppView: View {
    
    /// The global state manager for the application.
    @State var appState = AppState()
    
    var body: some View {
        AppBuilderView(
            isOnboardingCompleted: appState.isUserOnboardingCompleted,
            onboardingView: {
                OnboardingView(onFinished: {
                    appState.setIsUserOnboardingCompleted(true)
                })
            },
            tabView: {
                MainTabView()
            }
        )
        // Inject the SwiftData model container into the environment
        .modelContainer(for: [
            TaskItem.self,
            TaskSubtask.self,
            TaskList.self,
            TaskSpace.self
        ])
    }
}

#Preview("Onboarding Not Completed") {
    AppView(appState: AppState(isUserOnboardingCompleted: false))
}

#Preview("Onboarding Completed") {
    AppView(appState: AppState(isUserOnboardingCompleted: true))
}
