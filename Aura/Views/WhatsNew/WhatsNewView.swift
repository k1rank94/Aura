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
        VStack(alignment: .center, spacing: 32) {
            
            // Header
            VStack(spacing: 8) {
                Text("What's New in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Aura")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.pink)
            }
            .padding(.top, 40)
            
            // Feature List
            VStack(alignment: .leading, spacing: 28) {
                ForEach(items) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.icon)
                            .font(.system(size: 32, weight: .regular))
                            .foregroundColor(item.color)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                // Ensures long descriptions wrap nicely
                                .fixedSize(horizontal: false, vertical: true) 
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                HapticManager.shared.impact(style: .medium)
                dismiss()
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.pink)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .presentationBackground(Color(UIColor.systemBackground))
        .interactiveDismissDisabled() // Forces the user to tap "Continue" to acknowledge
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