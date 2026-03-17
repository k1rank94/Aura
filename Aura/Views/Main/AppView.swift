//
//  ContentView.swift
//  Aura
//
//  Created by Kiran on 27/02/26.
//

import SwiftUI
import SwiftData

struct AppView: View {
    
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
        .modelContainer(for: TaskItem.self)
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}

#Preview("Onboarding Not Completed") {
    AppView(appState: AppState(isUserOnboardingCompleted: false))
}
#Preview("Onboarding Completed") {
    AppView(appState: AppState(isUserOnboardingCompleted: true))
}

