# Aura 2.0

Aura is a calm, offline-first task manager for iPhone and iPad. Version 2.0 introduces the **Luminous Calm** design language: expressive enough to feel special, restrained enough to use every day.

## Highlights

- Three focused destinations: **Today**, **Plan**, and **Library**
- Animated daily progress and an overdue workflow
- A two-week planning rail with daily workload guidance
- Rich tasks with notes, priorities, estimates, recurrence, lists, and subtasks
- Fast global capture with thoughtful scheduling shortcuts
- Spaces and lists for larger areas of life
- Search across task titles, notes, and tags
- Recently completed history
- Morning and evening briefing notifications
- Siri and Shortcuts entry points for capture and navigation
- Small and medium Home Screen widgets
- Carefully art-directed light and dark appearances
- Dynamic Type and VoiceOver-friendly labels on primary interactions

## Architecture

Aura is built entirely with Apple frameworks:

- Swift 6 and SwiftUI
- SwiftData for local persistence
- Observation for app and routing state
- App Intents for Siri and Shortcuts
- WidgetKit for the Today widget
- UserNotifications for reminders and optional daily briefings

The main app owns the SwiftData store. The widget receives only a compact progress snapshot through the `group.com.kiran.Aura` App Group; it does not open or duplicate the task database.

## Requirements

- Xcode 15 or later
- iOS 17 or later
- An Apple development team with the App Group capability enabled for:
  - `com.kiran.Aura`
  - `com.kiran.Aura.widget`

## Run

1. Open `Aura.xcodeproj`.
2. Select the `Aura` scheme.
3. Confirm signing for both Aura targets.
4. Run on an iOS 17+ simulator or device.

If signing reports an App Group error, create or enable `group.com.kiran.Aura` in the Apple Developer portal and attach it to both targets.

## Privacy

Aura contains no analytics, advertising SDKs, accounts, or third-party dependencies. Tasks stay in the local SwiftData store. See [PRIVACY.md](PRIVACY.md).
