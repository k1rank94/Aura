//
//  AppBuilderView.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import SwiftUI

/// A dynamic container view that routes the user between the onboarding flow and the main application.
///
/// `AppBuilderView` uses a declarative approach to separate routing logic from view implementations.
/// By utilizing generic `@ViewBuilder` closures, it remains entirely decoupled from the specific
/// views it presents.
///
/// - Parameters:
///   - OnboardingView: The generic type of the view presented during the onboarding phase.
///   - TabView: The generic type of the view presented once onboarding is completed.
struct AppBuilderView<OnboardingView: View, TabView: View>: View {
    
    /// A flag determining which view to display.
    let isOnboardingCompleted: Bool
    
    /// A closure that builds the onboarding view.
    @ViewBuilder let onboardingView: () -> OnboardingView
    
    /// A closure that builds the main content view.
    @ViewBuilder let tabView: () -> TabView
    
    var body: some View {
        if isOnboardingCompleted {
            tabView()
        } else {
            onboardingView()
        }
    }
}

#Preview("Onboarding Completed") {
    AppBuilderView(
        isOnboardingCompleted: true,
        onboardingView: {
            Text("OnBoarding View")
                .foregroundStyle(.green)
        },
        tabView: {
            Text("Tab View")
                .foregroundStyle(.red)
        }
    )
}

#Preview("Onboarding Not Completed") {
    AppBuilderView(
        isOnboardingCompleted: false,
        onboardingView: {
            Text("OnBoarding View")
                .foregroundStyle(.green)
        },
        tabView: {
            Text("Tab View")
                .foregroundStyle(.red)
        }
    )
}

