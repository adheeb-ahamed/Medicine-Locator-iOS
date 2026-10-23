//
//  NotificationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import UserNotifications

/// Local notifications (no server, no paid account needed).
@MainActor
final class NotificationService: NSObject, NotificationServicing {
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self      // lets banners show while the app is open
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func notify(id: String, title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // trigger: nil = show now. Same id = replaces instead of duplicating.
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        try? await center.add(request)
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    /// By default iOS hides notifications while your app is open. This shows them as banners.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
