//
//  ScheduleNotificationView.swift
//  LocalNotificationsManager
//
//  Created by Sopnil Sohan on 2/12/25.
//

import SwiftUI

struct ScheduleNotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var selectedDate = Date().addingTimeInterval(60)
    @State private var repeats: Bool = false
    @State private var selectedRepeatInterval: RepeatInterval = .day
    @State private var includeDeepLink: Bool = false
    @State private var deepLinkPath: String = "/notifications"
    @State private var isScheduling = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                    
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.sentences)
                } header: {
                    Text("Notification Content")
                } footer: {
                    Text("Enter the title and message for your notification")
                }
                
                Section {
                    DatePicker(
                        "Schedule Date",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                } header: {
                    Text("Schedule")
                } footer: {
                    Text("Select when you want to receive this notification")
                }
                
                Section {
                    Toggle("Repeat Notification", isOn: $repeats)
                    
                    if repeats {
                        Picker("Repeat Interval", selection: $selectedRepeatInterval) {
                            ForEach(RepeatInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Repeat Options")
                } footer: {
                    Text("Choose if and how often the notification should repeat")
                }
                
                Section {
                    Toggle("Include Deep Link", isOn: $includeDeepLink)
                    
                    if includeDeepLink {
                        TextField("Deep Link Path", text: $deepLinkPath)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Deep Linking")
                } footer: {
                    Text("Add a deep link that will be triggered when the notification is tapped")
                }
                
                Section {
                    Button {
                        scheduleNotification()
                    } label: {
                        HStack {
                            if isScheduling {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isScheduling ? "Scheduling..." : "Schedule Notification")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(title.isEmpty || message.isEmpty || isScheduling)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Schedule Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleNotification() {
        guard !title.isEmpty, !message.isEmpty else { return }
        
        isScheduling = true
        
        var userInfo: [String: String] = [:]
        if includeDeepLink {
            userInfo["deepLink"] = deepLinkPath
        }
        
        let request = NotificationRequest(
            title: title,
            body: message,
            date: selectedDate,
            repeats: repeats,
            repeatInterval: repeats ? selectedRepeatInterval : nil,
            userInfo: userInfo
        )
        
        Task {
            do {
                try await notificationService.scheduleNotification(request)
                await MainActor.run {
                    isScheduling = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isScheduling = false
                }
            }
        }
    }
}

#Preview {
    ScheduleNotificationView()
}

