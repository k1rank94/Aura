//
//  AuraProgressHero.swift
//  Aura
//

import SwiftUI

struct AuraProgressHero: View {
    let completed: Int
    let total: Int
    @State private var animatedProgress = 0.0

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        HStack(spacing: AuraSpace.lg) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.white, AuraColor.mint, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(Int(animatedProgress * 100))")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.caption.bold())
                        .opacity(0.72)
                }
                .foregroundStyle(.white)
            }
            .frame(width: 108, height: 108)
            .shadow(color: AuraColor.violet.opacity(0.4), radius: 24)

            VStack(alignment: .leading, spacing: AuraSpace.sm) {
                Text(completed == total && total > 0 ? "Beautiful work." : "Your day,\nin focus.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(summary)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer(minLength: 0)
        }
        .padding(AuraSpace.lg)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AuraColor.auraGradient)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.14))
                        .frame(width: 150, height: 150)
                        .blur(radius: 12)
                        .offset(x: 50, y: -70)
                }
        }
        .shadow(color: AuraColor.violet.opacity(0.24), radius: 28, y: 18)
        .onAppear(perform: animate)
        .onChange(of: progress) { _, _ in animate() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completed) of \(total) tasks complete")
    }

    private var summary: String {
        guard total > 0 else { return "A clear canvas. Add one meaningful thing." }
        let remaining = total - completed
        return remaining == 0
            ? "Everything for today is complete."
            : "\(remaining) \(remaining == 1 ? "task" : "tasks") left today"
    }

    private func animate() {
        withAnimation(.spring(response: 0.9, dampingFraction: 0.82)) {
            animatedProgress = progress
        }
    }
}
