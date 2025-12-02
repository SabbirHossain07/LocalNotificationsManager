//
//  NotificationRequest.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import Foundation
import UserNotifications

/// Represents a scheduled notification request with all its properties
struct NotificationRequest: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let repeats: Bool
    let repeatInterval: RepeatInterval?
    let categoryIdentifier: String?
    let userInfo: [String: String]
    
    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        date: Date,
        repeats: Bool = false,
        repeatInterval: RepeatInterval? = nil,
        categoryIdentifier: String? = nil,
        userInfo: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.repeats = repeats
        self.repeatInterval = repeatInterval
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
    }
}

/// Represents different repeat intervals for notifications
enum RepeatInterval: String, Codable, CaseIterable {
    case minute = "Minute"
    case hour = "Hour"
    case day = "Day"
    case week = "Week"
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .minute: return .minute
        case .hour: return .hour
        case .day: return .day
        case .week: return .weekOfYear
        }
    }
    
    var value: Int {
        switch self {
        case .minute: return 1
        case .hour: return 1
        case .day: return 1
        case .week: return 1
        }
    }
}

/// Represents the authorization status for notifications
enum NotificationAuthorizationStatus: String {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case authorized = "Authorized"
    case provisional = "Provisional"
    case ephemeral = "Ephemeral"
    
    var canSchedule: Bool {
        self == .authorized || self == .provisional || self == .ephemeral
    }
}

/// Custom error types for notification operations
enum NotificationError: LocalizedError {
    case authorizationDenied
    case invalidDate
    case schedulingFailed(String)
    case cancellationFailed(String)
    case retrievalFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Notification permission was denied. Please enable notifications in Settings."
        case .invalidDate:
            return "The scheduled date must be in the future."
        case .schedulingFailed(let message):
            return "Failed to schedule notification: \(message)"
        case .cancellationFailed(let message):
            return "Failed to cancel notification: \(message)"
        case .retrievalFailed(let message):
            return "Failed to retrieve notifications: \(message)"
        }
    }
}

