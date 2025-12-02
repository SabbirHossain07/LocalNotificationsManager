//
//  LocalNotificationsManagerApp.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import SwiftUI
import UserNotifications

@main
struct LocalNotificationsManagerApp: App {
    @StateObject private var notificationService = NotificationService.shared
    private let notificationDelegate = NotificationDelegate()
    
    init() {
        setupNotificationCategories()
        setupNotificationDelegate()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationService)
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
    }
    
    // MARK: - Notification Categories Setup
    
    private func setupNotificationCategories() {
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_ACTION",
            title: "Accept",
            options: [.foreground]
        )
        
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_ACTION",
            title: "Decline",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: "NOTIFICATION_CATEGORY",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Notification Delegate Setup
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    // MARK: - Deep Link Handling
    
    private func handleDeepLink(url: URL) {
        // Handle deep links from notifications
        // This can be extended to navigate to specific views
        print("Deep link received: \(url.absoluteString)")
    }
}
