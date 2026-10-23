//
//  MockNotificationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import UserNotifications
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockNotificationService: NotificationServicing {
    var status: UNAuthorizationStatus = .authorized
    private(set) var sent: [(id: String, title: String, body: String)] = []

    func authorizationStatus() async -> UNAuthorizationStatus { status }
    func requestPermission() async -> Bool { status = .authorized; return true }
    func notify(id: String, title: String, body: String) async { sent.append((id, title, body)) }
}
