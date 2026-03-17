//
//  AppBuilderView.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import SwiftUI

struct AppBuilderView<OnboardingView: View, TabView: View>: View {
    let isOnboardingCompleted: Bool
    @ViewBuilder let onboardingView: () -> OnboardingView
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

