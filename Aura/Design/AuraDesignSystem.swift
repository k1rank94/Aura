//
//  AuraDesignSystem.swift
//  Aura
//

import SwiftUI

enum AuraColor {
    static let ink = Color(red: 0.08, green: 0.06, blue: 0.12)
    static let violet = Color(red: 0.43, green: 0.29, blue: 0.85)
    static let orchid = Color(red: 0.79, green: 0.31, blue: 0.75)
    static let coral = Color(red: 1.00, green: 0.43, blue: 0.38)
    static let mint = Color(red: 0.34, green: 0.78, blue: 0.69)
    static let sun = Color(red: 1.00, green: 0.72, blue: 0.28)

    static let auraGradient = LinearGradient(
        colors: [violet, orchid, coral],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let calmGradient = LinearGradient(
        colors: [violet.opacity(0.9), mint.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AuraSpace {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

struct AuraAmbientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("auraReduceGlow") private var reduceGlow = false

    var body: some View {
        ZStack {
            (colorScheme == .dark ? AuraColor.ink : Color(red: 0.97, green: 0.96, blue: 0.99))
                .ignoresSafeArea()

            Circle()
                .fill(AuraColor.orchid.opacity(reduceGlow ? 0.04 : (colorScheme == .dark ? 0.22 : 0.16)))
                .frame(width: 310, height: 310)
                .blur(radius: 75)
                .offset(x: 150, y: -290)

            Circle()
                .fill(AuraColor.violet.opacity(reduceGlow ? 0.03 : (colorScheme == .dark ? 0.18 : 0.11)))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -160, y: 290)

            Circle()
                .fill(AuraColor.mint.opacity(reduceGlow ? 0.02 : (colorScheme == .dark ? 0.10 : 0.08)))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: 150, y: 480)
        }
        .accessibilityHidden(true)
    }
}

struct AuraCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    let isElevated: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.09)
                                    : Color.white.opacity(0.78),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(isElevated ? (colorScheme == .dark ? 0.24 : 0.08) : 0),
                        radius: isElevated ? 22 : 0,
                        y: isElevated ? 12 : 0
                    )
            }
    }
}

extension View {
    func auraCard(cornerRadius: CGFloat = 24, elevated: Bool = false) -> some View {
        modifier(AuraCardModifier(cornerRadius: cornerRadius, isElevated: elevated))
    }
}

struct AuraSectionHeading: View {
    let eyebrow: String?
    let title: String
    let trailing: String?

    init(_ title: String, eyebrow: String? = nil, trailing: String? = nil) {
        self.title = title
        self.eyebrow = eyebrow
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.4)
                        .foregroundStyle(AuraColor.orchid)
                }

                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct AuraEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AuraSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(AuraColor.auraGradient)
                .frame(width: 68, height: 68)
                .background(AuraColor.violet.opacity(0.10), in: Circle())

            VStack(spacing: AuraSpace.xs) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, AuraSpace.lg)
        .auraCard()
    }
}
