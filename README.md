# Aura 📱✨

Aura is a premium, offline-first task management iOS application designed with a focus on fluid interactions, high-contrast typography, and uncompromising performance. 

Built entirely from scratch using **Swift 6** and **iOS 17**, Aura demonstrates modern iOS architectural patterns, eschewing heavy third-party libraries in favor of optimized native APIs.

![Add task](https://github.com/user-attachments/assets/d0322c15-498d-4089-b009-413ab1507eda) ![Screen Recording 2026-03-18 at 10 27 18 AM](https://github.com/user-attachments/assets/584893a9-a6b6-4223-b56f-00d7e779a9a3) ![Screen Recording 2026-03-18 at 10 34 35 AM](https://github.com/user-attachments/assets/4fa62d7a-a150-4736-b285-aa2a3f082426)



---

## ✨ Core Features

* **Dynamic Intelligent Routing:** Tasks are automatically routed to the `Inbox`, `Today`, or `Upcoming` tabs based on their assigned `dueDate`.
* **Interactive Bottom Sheets:** Custom-styled modal presentations featuring dynamic state validation, custom tag generation, and native interactive-dismiss protection.
* **Granular Reminders:** Integrated `UserNotifications` framework schedules background alerts tied directly to the task's unique UUID.
* **Fluid Gestures:** Fully supports native iOS swipe-to-delete gestures on custom-styled, floating-card UI components.
* **Real-time Search:** A custom-built search interface that filters the database instantly while supporting interactive keyboard dismissal.

---

## 🏗️ Technical Architecture

Aura was built to showcase clean separation of concerns and modern data handling. 

### 1. MVVM with SwiftData
The app utilizes the **Model-View-ViewModel (MVVM)** design pattern paired with Apple's new `SwiftData` framework. 
* **The Brains:** ViewModels handle complex business logic (e.g., date math, sorting morning vs. afternoon tasks, calculating progress ring percentages).
* **The Pipeline:** Views leverage the `@Query` and `#Predicate` macros to maintain a real-time, highly optimized pipeline directly to the local SQLite database, eliminating the need for manual state synchronization.

### 2. Custom UI over Native Skeletons
Rather than fighting the framework, Aura heavily styles native SwiftUI components to achieve a custom design language:
* Converted standard `List` components into floating card layouts using `listRowBackground(.clear)` and `listRowInsets`, preserving native `.swipeActions`.
* Overrode default iOS 17 frosted-glass sheet materials with `.presentationBackground(.white)` for a crisp, high-contrast aesthetic.
* Encapsulated Apple's native `DatePicker` behind custom UI pills to maintain visual consistency without sacrificing accessibility.

### 3. Notification Management
A dedicated, thread-safe `@MainActor NotificationManager` singleton handles all `UNUserNotificationCenter` requests. By binding the Notification Request Identifier directly to the SwiftData `TaskItem.id`, the app completely mitigates duplicated or orphaned background alerts when tasks are edited or deleted.

---

## 🛠️ Requirements

* iOS 17.0+
* Xcode 15.0+
* Swift 5.9+ / Swift 6

---

# Aura 📱✨

Aura is a premium, offline-first task management iOS application designed with a focus on fluid interactions, high-contrast typography, and uncompromising performance. 

Built entirely from scratch using **Swift 6** and **iOS 17**, Aura demonstrates modern iOS architectural patterns, eschewing heavy third-party libraries in favor of optimized native APIs.

![Swift](https://img.shields.io/badge/Swift-6.0-F05138.svg) ![iOS](https://img.shields.io/badge/iOS-17.0+-000000.svg) ![Architecture](https://img.shields.io/badge/Architecture-MVVM-blue.svg) ![Framework](https://img.shields.io/badge/Framework-SwiftUI-blue.svg) ![Database](https://img.shields.io/badge/Database-SwiftData-orange.svg)

---

## ✨ Core Features

* **Dynamic Intelligent Routing:** Tasks are automatically routed to the `Inbox`, `Today`, or `Upcoming` tabs based on their assigned `dueDate`.
* **Interactive Bottom Sheets:** Custom-styled modal presentations featuring dynamic state validation, custom tag generation, and native interactive-dismiss protection.
* **Granular Reminders:** Integrated `UserNotifications` framework schedules background alerts tied directly to the task's unique UUID.
* **Fluid Gestures:** Fully supports native iOS swipe-to-delete gestures on custom-styled, floating-card UI components.
* **Real-time Search:** A custom-built search interface that filters the database instantly while supporting interactive keyboard dismissal.

---

## 🏗️ Technical Architecture

Aura was built to showcase clean separation of concerns and modern data handling. 

### 1. MVVM with SwiftData
The app utilizes the **Model-View-ViewModel (MVVM)** design pattern paired with Apple's new `SwiftData` framework. 
* **The Brains:** ViewModels handle complex business logic (e.g., date math, sorting morning vs. afternoon tasks, calculating progress ring percentages).
* **The Pipeline:** Views leverage the `@Query` and `#Predicate` macros to maintain a real-time, highly optimized pipeline directly to the local SQLite database, eliminating the need for manual state synchronization.

### 2. Custom UI over Native Skeletons
Rather than fighting the framework, Aura heavily styles native SwiftUI components to achieve a custom design language:
* Converted standard `List` components into floating card layouts using `listRowBackground(.clear)` and `listRowInsets`, preserving native `.swipeActions`.
* Overrode default iOS 17 frosted-glass sheet materials with `.presentationBackground(.white)` for a crisp, high-contrast aesthetic.
* Encapsulated Apple's native `DatePicker` behind custom UI pills to maintain visual consistency without sacrificing accessibility.

### 3. Notification Management
A dedicated, thread-safe `@MainActor NotificationManager` singleton handles all `UNUserNotificationCenter` requests. By binding the Notification Request Identifier directly to the SwiftData `TaskItem.id`, the app completely mitigates duplicated or orphaned background alerts when tasks are edited or deleted.

---

## 🛠️ Requirements

* iOS 17.0+
* Xcode 15.0+
* Swift 5.9+ / Swift 6

---

## 🚀 Installation & Setup

1. Clone the repository:
   ```bash
   git clone [https://github.com/k1rank94/Aura.git](https://github.com/k1rank94/Aura.git)
