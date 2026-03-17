//
//  OnboardingView.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import SwiftUI

// MARK: - Onboarding Data Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Onboarding View
struct OnboardingView: View {
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "bg_onboarding_page_1",
            title: "Simplify Your Day",
            subtitle: "Organize your tasks and clear your\nmind."
        ),
        OnboardingPage(
            imageName: "bg_onboarding_page_2",
            title: "Achieve More",
            subtitle: "Track your progress and hit your\ngoals."
        )
    ]
    
    @State private var currentPage = 0
    var onFinished: () -> Void
    
    var body: some View {
        VStack {
            // Paging View
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    let page = pages[index]
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Image Placeholder
                        Image(page.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250, maxHeight: 250)
                            // Fallback styling so you can see the layout before adding images
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                        
                        // Text Content
                        VStack(spacing: 16) {
                            Text(page.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(page.subtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            // Trigger selection haptic when the user swipes between pages
            .onChange(of: currentPage) { _ in
                HapticManager.shared.selection()
            }
            
            // Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        // Using the app's accent color (which you already set) for the active dot
                        .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 32)
            
            // Action Button
            Button {
                if currentPage < pages.count - 1 {
                    // Light impact haptic for advancing pages
                    HapticManager.shared.impact(style: .light)
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    // Success haptic for completing onboarding
                    HapticManager.shared.notification(type: .success)
                    onFinished()
                }
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    // Uses your set accent color
                    .background(Color.accentColor)
                    .cornerRadius(16)
                    // Adds a subtle matching glow/shadow from your design
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    OnboardingView(onFinished: {
        print("Onboarding Complete!")
    })
}
