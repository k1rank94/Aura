//
//  SettingsView.swift
//  Aura
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isMorningBriefingEnabled") private var isMorningBriefingEnabled = false
    @AppStorage("isEveningBriefingEnabled") private var isEveningBriefingEnabled = false
    @AppStorage("auraReduceGlow") private var reduceGlow = false

    var body: some View {
        ZStack {
            AuraAmbientBackground()

            ScrollView {
                VStack(spacing: AuraSpace.lg) {
                    identityCard
                    notificationSettings
                    appearanceSettings
                    aboutCard
                }
                .padding(AuraSpace.lg)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AuraColor.orchid)
    }

    private var identityCard: some View {
        HStack(spacing: AuraSpace.md) {
            ZStack {
                Circle()
                    .fill(AuraColor.auraGradient)
                    .frame(width: 62, height: 62)
                Image(systemName: "sparkles")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Aura")
                    .font(.title2.weight(.black))
                Text("Your calm space to get things done.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(AuraSpace.lg)
        .auraCard(elevated: true)
    }

    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            AuraSectionHeading("Daily rhythm", eyebrow: "Notifications")

            VStack(spacing: 0) {
                Toggle(isOn: $isMorningBriefingEnabled) {
                    SettingsLabel(
                        icon: "sunrise.fill",
                        color: AuraColor.sun,
                        title: "Morning briefing",
                        subtitle: "8:00 AM"
                    )
                }
                .onChange(of: isMorningBriefingEnabled) { _, enabled in
                    if enabled {
                        NotificationManager.shared.requestAuthorization()
                    }
                    NotificationManager.shared.updateMorningBriefing(isEnabled: enabled)
                }

                Divider().padding(.leading, 52)

                Toggle(isOn: $isEveningBriefingEnabled) {
                    SettingsLabel(
                        icon: "moon.stars.fill",
                        color: AuraColor.violet,
                        title: "Evening reflection",
                        subtitle: "8:00 PM"
                    )
                }
                .onChange(of: isEveningBriefingEnabled) { _, enabled in
                    if enabled {
                        NotificationManager.shared.requestAuthorization()
                    }
                    NotificationManager.shared.updateEveningBriefing(isEnabled: enabled)
                }
            }
            .padding(AuraSpace.md)
            .auraCard(cornerRadius: 20)
        }
    }

    private var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: AuraSpace.sm) {
            AuraSectionHeading("Atmosphere", eyebrow: "Appearance")

            Toggle(isOn: $reduceGlow) {
                SettingsLabel(
                    icon: "lightbulb.min.fill",
                    color: AuraColor.orchid,
                    title: "Reduce ambient glow",
                    subtitle: "A quieter background"
                )
            }
            .padding(AuraSpace.md)
            .auraCard(cornerRadius: 20)
        }
    }

    private var aboutCard: some View {
        VStack(spacing: AuraSpace.sm) {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0")
                    .foregroundStyle(.secondary)
            }
            Divider()
            Link(destination: URL(string: "https://github.com/k1rank94/Aura")!) {
                HStack {
                    Text("View project")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
            }
        }
        .font(.subheadline.weight(.medium))
        .padding(AuraSpace.md)
        .auraCard(cornerRadius: 20)
    }
}

private struct SettingsLabel: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: AuraSpace.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
