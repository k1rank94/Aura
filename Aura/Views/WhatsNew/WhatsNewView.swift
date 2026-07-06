//
//  WhatsNewItem.swift
//  Aura
//
//  Created by Kiran on 01/04/26.
//


//
//  WhatsNewView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI

// MARK: - Data Model

/// A simple structure to hold the details of a new feature.
struct WhatsNewItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - UI View

/// A polished, Apple-style modal that displays the latest features to the user.
struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// The list of features to display in this update.
    let items: [WhatsNewItem]
    
    var body: some View {
        ZStack {
            AuraAmbientBackground()

            VStack(alignment: .center, spacing: AuraSpace.xl) {
                VStack(spacing: AuraSpace.sm) {
                    Image(systemName: "sparkles")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(AuraColor.auraGradient, in: Circle())
                        .shadow(color: AuraColor.orchid.opacity(0.28), radius: 20, y: 10)

                    Text("Aura, reimagined")
                        .font(.system(size: 34, weight: .black, design: .rounded))

                    Text("A calmer, richer way to shape your days.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, AuraSpace.xl)

                VStack(alignment: .leading, spacing: AuraSpace.sm) {
                    ForEach(items) { item in
                        HStack(spacing: AuraSpace.md) {
                            Image(systemName: item.icon)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(item.color)
                                .frame(width: 46, height: 46)
                                .background(item.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)

                                Text(item.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(AuraSpace.md)
                        .auraCard(cornerRadius: 20)
                    }
                }

                Spacer()

                Button(action: continueToApp) {
                    HStack {
                        Text("Enter Aura")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AuraSpace.lg)
                    .frame(height: 56)
                    .background(AuraColor.auraGradient, in: RoundedRectangle(cornerRadius: 19))
                }
                .padding(.bottom, AuraSpace.lg)
            }
            .padding(.horizontal, AuraSpace.lg)
        }
        .interactiveDismissDisabled()
    }

    private func continueToApp() {
        HapticManager.shared.impact(style: .medium)
        dismiss()
    }
}

// MARK: - Preview with the current update data!
#Preview {
    WhatsNewView(items: [
        WhatsNewItem(icon: "moon.stars.fill", title: "Dark Mode", description: "Aura now beautifully adapts to your system's dark mode settings for late-night planning.", color: .indigo),
        WhatsNewItem(icon: "repeat", title: "Recurring Tasks", description: "Automate your workflow. Set tasks to repeat daily, weekly, or monthly.", color: .pink),
        WhatsNewItem(icon: "bell.badge.fill", title: "Daily Nudges", description: "Start your morning right and wind down easily with automated daily briefing notifications.", color: .orange)
    ])
}
