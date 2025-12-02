//
//  NotificationsDemoView.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import SwiftUI

struct NotificationsDemoView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingScheduleSheet = false
    @State private var showingPendingList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Permission Status Card
                        permissionStatusCard
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Stats Cards
                        statsSection
                        
                        // Pending Notifications Preview
                        if !notificationService.pendingNotifications.isEmpty {
                            pendingNotificationsPreview
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPendingList = true
                    } label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingScheduleSheet) {
                ScheduleNotificationView()
            }
            .sheet(isPresented: $showingPendingList) {
                PendingNotificationsView()
            }
            .alert("Error", isPresented: .constant(notificationService.errorMessage != nil)) {
                Button("OK") {
                    notificationService.errorMessage = nil
                }
            } message: {
                if let error = notificationService.errorMessage {
                    Text(error)
                }
            }
            .task {
                await notificationService.checkAuthorizationStatus()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Local Notifications Manager")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Schedule, manage, and track your notifications")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Permission Status Card
    
    private var permissionStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: permissionStatusIcon)
                    .font(.title2)
                    .foregroundColor(permissionStatusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Permission Status")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(notificationService.authorizationStatus.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            if notificationService.authorizationStatus != .authorized {
                Button {
                    Task {
                        await notificationService.requestAuthorization()
                    }
                } label: {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("Request Permission")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.2, opacity: 0.6))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(permissionStatusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var permissionStatusIcon: String {
        switch notificationService.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        }
    }
    
    private var permissionStatusColor: Color {
        switch notificationService.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    icon: "plus.circle.fill",
                    title: "Schedule",
                    color: .blue,
                    action: {
                        showingScheduleSheet = true
                    }
                )
                
                ActionButton(
                    icon: "list.bullet.rectangle.fill",
                    title: "Pending",
                    color: .purple,
                    action: {
                        showingPendingList = true
                    }
                )
                
                ActionButton(
                    icon: "xmark.circle.fill",
                    title: "Cancel All",
                    color: .red,
                    action: {
                        Task {
                            try? await notificationService.cancelAllNotifications()
                        }
                    }
                )
                
                ActionButton(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Refresh",
                    color: .orange,
                    action: {
                        Task {
                            await notificationService.loadPendingNotifications()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "bell.fill",
                value: "\(notificationService.pendingNotifications.count)",
                label: "Pending",
                color: .blue
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                value: notificationService.authorizationStatus.canSchedule ? "Yes" : "No",
                label: "Authorized",
                color: notificationService.authorizationStatus.canSchedule ? .green : .red
            )
        }
    }
    
    // MARK: - Pending Notifications Preview
    
    private var pendingNotificationsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    showingPendingList = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 4)
            
            ForEach(Array(notificationService.pendingNotifications.prefix(3))) { notification in
                NotificationPreviewRow(notification: notification)
            }
        }
    }
}

// MARK: - Supporting Views

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.2, opacity: 0.6))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2, opacity: 0.6))
        )
    }
}

struct NotificationPreviewRow: View {
    let notification: NotificationRequest
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(notification.body)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(notification.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white)
                
                if notification.repeats {
                    Text("Repeats")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2, opacity: 0.6))
        )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NotificationsDemoView()
}

