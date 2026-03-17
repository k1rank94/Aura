//
//  HapticManager.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//


import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Triggers a standard physical impact feedback (e.g., for button presses)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a notification feedback (e.g., for success, warning, or error states)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Triggers a subtle selection feedback (e.g., swiping between pages, scrolling pickers)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
