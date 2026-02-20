//
//  LocalNotifications.swift
//  Forge
//
//  Local notifications helper
//

import UserNotifications

enum LocalNotifications {

    static func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        return granted
    }

    static func canRequestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .notDetermined
    }

    static func scheduleNotification(content: AnyNotificationContent, trigger: NotificationTriggerOption) async throws {
        let center = UNUserNotificationCenter.current()

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.title
        notificationContent.body = content.body
        if let sound = content.sound {
            notificationContent.sound = sound
        }

        let notificationTrigger: UNNotificationTrigger
        switch trigger {
        case .date(let date, let repeats):
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            notificationTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        case .timeInterval(let interval, let repeats):
            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: notificationTrigger
        )

        try await center.add(request)
    }
}

struct AnyNotificationContent {
    let title: String
    let body: String
    let sound: UNNotificationSound?

    init(title: String, body: String, sound: UNNotificationSound? = .default) {
        self.title = title
        self.body = body
        self.sound = sound
    }
}

enum NotificationTriggerOption {
    case date(date: Date, repeats: Bool)
    case timeInterval(interval: TimeInterval, repeats: Bool)
}
