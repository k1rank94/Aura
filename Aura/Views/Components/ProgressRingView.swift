//
//  ProgressRingView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//


import SwiftUI

struct ProgressRingView: View {
    var progress: Double // Example: 0.68 for 68%
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 6)
            
            // Progress track
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.pink, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Start from the top
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            // Text inside
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.pink)
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    ProgressRingView(progress: 0.68)
        .padding()
}