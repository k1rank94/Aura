//
//  OnboardingView.swift
//  Aura
//

import SwiftUI

struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            eyebrow: "WELCOME TO AURA",
            title: "Make room for\nwhat matters.",
            subtitle: "A calm, beautiful place for the tasks that deserve your attention.",
            symbol: "sparkles",
            colors: [AuraColor.violet, AuraColor.orchid, AuraColor.coral]
        ),
        OnboardingPage(
            eyebrow: "PLAN WITH INTENTION",
            title: "See your time.\nProtect your energy.",
            subtitle: "Shape today, look ahead, and keep demanding days realistic.",
            symbol: "calendar",
            colors: [AuraColor.violet, AuraColor.mint]
        ),
        OnboardingPage(
            eyebrow: "BUILD MOMENTUM",
            title: "Small steps.\nBeautiful progress.",
            subtitle: "Break work down, capture quickly, and let every completion feel satisfying.",
            symbol: "checkmark",
            colors: [AuraColor.orchid, AuraColor.coral, AuraColor.sun]
        )
    ]

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    HapticManager.shared.selection()
                }

                pageIndicator
                continueButton
            }
            .padding(.bottom, AuraSpace.lg)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AuraColor.orchid : Color.secondary.opacity(0.22))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: currentPage)
            }
        }
        .padding(.bottom, AuraSpace.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")
    }

    private var continueButton: some View {
        Button(action: advance) {
            HStack {
                Text(currentPage == pages.count - 1 ? "Enter Aura" : "Continue")
                Spacer()
                Image(systemName: currentPage == pages.count - 1 ? "sparkles" : "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, AuraSpace.lg)
            .frame(height: 58)
            .background(AuraColor.auraGradient, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: AuraColor.orchid.opacity(0.28), radius: 20, y: 10)
        }
        .padding(.horizontal, AuraSpace.lg)
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentPage += 1
            }
        } else {
            HapticManager.shared.notification(type: .success)
            onFinished()
        }
    }
}

private struct OnboardingPage {
    let eyebrow: String
    let title: String
    let subtitle: String
    let symbol: String
    let colors: [Color]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AuraSpace.xl) {
            Spacer(minLength: 50)

            hero

            VStack(spacing: AuraSpace.md) {
                Text(page.eyebrow)
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(AuraColor.orchid)

                Text(page.title)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineSpacing(-2)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, AuraSpace.xl)
            }

            Spacer()
        }
        .padding(.horizontal, AuraSpace.lg)
    }

    private var hero: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: page.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220, height: 220)
                .shadow(color: page.colors.first?.opacity(0.28) ?? .clear, radius: 38, y: 20)

            Circle()
                .stroke(.white.opacity(0.24), lineWidth: 1)
                .frame(width: 176, height: 176)

            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 118, height: 118)

            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
                .symbolEffect(.pulse)
        }
        .accessibilityHidden(true)
    }
}
