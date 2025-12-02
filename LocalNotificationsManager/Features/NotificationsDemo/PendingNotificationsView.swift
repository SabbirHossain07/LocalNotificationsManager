//
//  PendingNotificationsView.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import SwiftUI

struct PendingNotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if notificationService.pendingNotifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Pending Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        refreshNotifications()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(
                                isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isRefreshing
                            )
                    }
                }
            }
            .task {
                await notificationService.loadPendingNotifications()
            }
        }
    }
    
    // MARK: - Notifications List
    
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notificationService.pendingNotifications) { notification in
                    NotificationDetailRow(notification: notification)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Pending Notifications")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Schedule a notification to see it here")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func refreshNotifications() {
        isRefreshing = true
        Task {
            await notificationService.loadPendingNotifications()
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
}

// MARK: - Notification Detail Row

struct NotificationDetailRow: View {
    let notification: NotificationRequest
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(notification.body)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                Label {
                    Text(notification.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Label {
                    Text(notification.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
            }
            
            if notification.repeats, let interval = notification.repeatInterval {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(.purple)
                    Text("Repeats every \(interval.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            if !notification.userInfo.isEmpty {
                if let deepLink = notification.userInfo["deepLink"] {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.green)
                        Text("Deep Link: \(deepLink)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Button {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Cancel Notification")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.2, opacity: 0.6))
        )
        .confirmationDialog(
            "Cancel Notification",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await notificationService.cancelNotification(id: notification.id)
                }
            }
        } message: {
            Text("Are you sure you want to cancel this notification?")
        }
    }
}

#Preview {
    PendingNotificationsView()
}

