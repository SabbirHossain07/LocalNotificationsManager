# 🔔 Local Notifications Manager

A comprehensive, production-ready iOS app demonstrating end-to-end local notifications management with beautiful UI/UX, built with SwiftUI.

## ✨ Features

- **🔐 Permission Flow**: Seamless notification permission request with clear status indicators
- **📅 Schedule Notifications**: Schedule one-time or recurring notifications with custom intervals
- **🔄 Repeat Options**: Support for minute, hour, day, and week repeat intervals
- **❌ Cancel Notifications**: Cancel individual or all pending notifications
- **📋 Pending Request List**: View and manage all scheduled notifications
- **🔗 Deep Link Example**: Handle deep links from notifications to navigate within the app
- **⚠️ Error Handling**: Comprehensive error handling with user-friendly messages
- **🎨 Modern UI/UX**: Beautiful, accessible interface with smooth animations

## 🏗️ Architecture

The project follows clean architecture principles with clear separation of concerns:

```
LocalNotificationsManager/
├── Models/
│   └── NotificationRequest.swift      # Data models and enums
├── Services/
│   └── NotificationService.swift      # Core notification management service
├── Features/
│   └── NotificationsDemo/
│       └── Views/
│           ├── NotificationsDemoView.swift      # Main demo view
│           ├── ScheduleNotificationView.swift   # Schedule notification form
│           └── PendingNotificationsView.swift    # Pending notifications list
└── LocalNotificationsManagerApp.swift  # App entry point with deep link handling
```

## 🚀 Getting Started

### Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/LocalNotificationsManager.git
cd LocalNotificationsManager
```

2. Open the project in Xcode:
```bash
open LocalNotificationsManager.xcodeproj
```

3. Build and run the project (⌘R)

## 📱 Usage

### Requesting Permissions

The app automatically checks notification permissions on launch. If permissions are not granted, tap the "Request Permission" button to prompt the user.

### Scheduling a Notification

1. Tap the "Schedule" button on the main screen
2. Fill in the notification title and message
3. Select a date and time
4. Optionally enable repeat and choose an interval
5. Optionally add a deep link path
6. Tap "Schedule Notification"

### Viewing Pending Notifications

- Tap the list icon in the navigation bar, or
- Tap the "Pending" quick action button, or
- Scroll down to see the preview of upcoming notifications

### Canceling Notifications

- Cancel a single notification: Open the pending list and tap "Cancel Notification" on the desired item
- Cancel all notifications: Tap the "Cancel All" quick action button

### Deep Linking

When scheduling a notification, you can include a deep link path. When the notification is tapped, the app will receive the deep link URL and can navigate to the appropriate view.

## 🎨 UI/UX Highlights

- **Dark Theme**: Beautiful dark gradient background with glassmorphism effects
- **Smooth Animations**: Scale animations on button presses and smooth transitions
- **Status Indicators**: Color-coded permission status with clear visual feedback
- **Empty States**: Helpful empty state views when no notifications are scheduled
- **Error Handling**: User-friendly error messages with automatic dismissal
- **Accessibility**: Proper labels and semantic structure for VoiceOver support

## 🔧 Technical Details

### NotificationService

The `NotificationService` is a singleton `ObservableObject` that manages all notification operations:

- **Authorization**: Request and check notification permissions
- **Scheduling**: Schedule notifications with various trigger types
- **Cancellation**: Cancel individual or all pending notifications
- **Retrieval**: Load and display all pending notifications
- **Error Handling**: Centralized error handling with user-friendly messages

### Models

- `NotificationRequest`: Represents a notification with all its properties
- `RepeatInterval`: Enum for different repeat intervals
- `NotificationAuthorizationStatus`: Enum for permission states
- `NotificationError`: Custom error types with localized descriptions

### Deep Linking

Deep links are handled in the app's entry point. When a notification with a deep link is tapped, the `onOpenURL` modifier receives the URL and can route to the appropriate view.

## 📝 Code Quality

- ✅ Clean, readable code following Swift best practices
- ✅ Comprehensive error handling
- ✅ Proper use of async/await for asynchronous operations
- ✅ ObservableObject pattern for reactive UI updates
- ✅ Separation of concerns with dedicated service layer
- ✅ Reusable UI components
- ✅ Proper documentation and comments

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

**Sopnil Sohan**

- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Built with SwiftUI and UserNotifications framework
- Inspired by modern iOS design patterns and best practices

---

⭐ If you find this project helpful, please consider giving it a star!

