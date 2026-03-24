//
//  ProgressRingView.swift
//  Aura
//
//  Created by Kiran on 16/03/26.
//

import SwiftUI

/// A custom graphical component that displays a circular progress indicator.
///
/// `ProgressRingView` visually represents a percentage-based completion state,
/// filling a highlighted track along the perimeter of a circle. It automatically
/// animates to new values using a spring animation.
struct ProgressRingView: View {
    
    /// The current progress value, represented as a decimal between 0.0 and 1.0.
    /// Example: `0.68` represents 68%.
    var progress: Double 
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 6)
            
            // Progress track
            Circle()
                // Trim the circle to match the given progress
                .trim(from: 0.0, to: progress)
                .stroke(Color.pink, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                // Rotate by -90 degrees so the progress starts from the top (12 o'clock)
                .rotationEffect(.degrees(-90)) 
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            // Textual representation
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
