//
//  NotificationService.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import Foundation
import UserNotifications
import Combine

/// Service responsible for managing local notifications
/// Handles permissions, scheduling, cancellation, and retrieval of notifications
@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: NotificationAuthorizationStatus = .notDetermined
    @Published var pendingNotifications: [NotificationRequest] = []
    @Published var errorMessage: String?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Requests notification permissions from the user
    /// - Returns: True if authorized, false otherwise
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            
            await checkAuthorizationStatus()
            return granted
        } catch {
            await handleError(.schedulingFailed(error.localizedDescription))
            return false
        }
    }
    
    /// Checks the current authorization status
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .authorized:
            authorizationStatus = .authorized
        case .provisional:
            authorizationStatus = .provisional
        case .ephemeral:
            authorizationStatus = .ephemeral
        @unknown default:
            authorizationStatus = .notDetermined
        }
        
        await loadPendingNotifications()
    }
    
    // MARK: - Scheduling
    
    /// Schedules a notification request
    /// - Parameter request: The notification request to schedule
    /// - Throws: NotificationError if scheduling fails
    func scheduleNotification(_ request: NotificationRequest) async throws {
        guard authorizationStatus.canSchedule else {
            throw NotificationError.authorizationDenied
        }
        
        guard request.date > Date() else {
            throw NotificationError.invalidDate
        }
        
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.userInfo = request.userInfo
        
        if let categoryIdentifier = request.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        let trigger: UNNotificationTrigger
        
        // Use calendar trigger for better accuracy with specific dates
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: request.date
        )
        
        if request.repeats, let repeatInterval = request.repeatInterval {
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
        } else {
            // For one-time notifications, use calendar trigger for exact time
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
        }
        
        let notificationRequest = UNNotificationRequest(
            identifier: request.id,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(notificationRequest)
            await loadPendingNotifications()
        } catch {
            throw NotificationError.schedulingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Cancellation
    
    /// Cancels a specific notification by ID
    /// - Parameter id: The identifier of the notification to cancel
    func cancelNotification(id: String) async throws {
        do {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
            await loadPendingNotifications()
        } catch {
            throw NotificationError.cancellationFailed(error.localizedDescription)
        }
    }
    
    /// Cancels all pending notifications
    func cancelAllNotifications() async throws {
        do {
            notificationCenter.removeAllPendingNotificationRequests()
            await loadPendingNotifications()
        } catch {
            throw NotificationError.cancellationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Retrieval
    
    /// Loads all pending notifications from the system
    func loadPendingNotifications() async {
        do {
            let pending = await notificationCenter.pendingNotificationRequests()
            
            pendingNotifications = pending.compactMap { request in
                guard let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                      let nextTriggerDate = trigger.nextTriggerDate() else {
                    // Handle calendar-based triggers
                    if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
                       let nextDate = calendarTrigger.nextTriggerDate() {
                        return NotificationRequest(
                            id: request.identifier,
                            title: request.content.title,
                            body: request.content.body,
                            date: nextDate,
                            repeats: calendarTrigger.repeats,
                            repeatInterval: calendarTrigger.repeats ? .day : nil,
                            categoryIdentifier: request.content.categoryIdentifier.isEmpty ? nil : request.content.categoryIdentifier,
                            userInfo: request.content.userInfo as? [String: String] ?? [:]
                        )
                    }
                    return nil
                }
                
                return NotificationRequest(
                    id: request.identifier,
                    title: request.content.title,
                    body: request.content.body,
                    date: nextTriggerDate,
                    repeats: trigger.repeats,
                    repeatInterval: trigger.repeats ? .minute : nil,
                    categoryIdentifier: request.content.categoryIdentifier.isEmpty ? nil : request.content.categoryIdentifier,
                    userInfo: request.content.userInfo as? [String: String] ?? [:]
                )
            }
            .sorted { $0.date < $1.date }
        } catch {
            await handleError(.retrievalFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: NotificationError) async {
        errorMessage = error.errorDescription
        // Clear error after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                errorMessage = nil
            }
        }
    }
    
    // MARK: - Deep Linking
    
    /// Handles deep link from notification
    /// - Parameter userInfo: The userInfo dictionary from the notification
    /// - Returns: Deep link path if available
    func handleDeepLink(userInfo: [AnyHashable: Any]) -> String? {
        return userInfo["deepLink"] as? String
    }
}

