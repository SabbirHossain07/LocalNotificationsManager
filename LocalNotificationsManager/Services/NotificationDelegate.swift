//
//  NotificationDelegate.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import Foundation
import UserNotifications
import SwiftUI

/// Handles notification interactions and deep linking
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Notification Received (Foreground)
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Notification Tapped
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle deep link if present
        if let deepLink = userInfo["deepLink"] as? String {
            handleDeepLink(path: deepLink)
        }
        
        // Handle action buttons
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("Accept action tapped")
        case "DECLINE_ACTION":
            print("Decline action tapped")
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Deep Link Handling
    
    private func handleDeepLink(path: String) {
        // Create URL from path
        guard let url = URL(string: "localnotifications://\(path)") else {
            print("Invalid deep link path: \(path)")
            return
        }
        
        // Post notification to handle deep link
        NotificationCenter.default.post(
            name: NSNotification.Name("DeepLinkNotification"),
            object: nil,
            userInfo: ["url": url]
        )
    }
}

