//
//  HapticManager.swift
//  Aura
//
//  Created by Kiran on 13/03/26.
//

import UIKit

/// A centralized singleton manager responsible for triggering haptic feedback across the application.
///
/// `HapticManager` wraps UIKit's various `UIFeedbackGenerator` subclasses into a simple,
/// declarative API. Utilizing haptics improves the tactile response of the application, particularly
/// during onboarding flows, task completion, and destructive actions.
final class HapticManager {
    
    /// The shared singleton instance of the haptic manager.
    static let shared = HapticManager()
    
    // Prevent external initialization
    private init() {}
    
    /// Triggers a standard physical impact feedback.
    ///
    /// Use this feedback for standard interactions, such as tapping prominent buttons or concluding a drag gesture.
    ///
    /// - Parameter style: The style of the impact feedback. Defaults to `.medium`.
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a notification feedback indicating a status change.
    ///
    /// Use this feedback to communicate the outcome of a task, such as a success, warning, or error state.
    ///
    /// - Parameter type: The specific type of notification feedback to generate.
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Triggers a subtle selection feedback.
    ///
    /// Use this feedback for continuous but lightweight interactions, such as swiping between
    /// pages in a `TabView` or scrolling through a custom picker.
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
