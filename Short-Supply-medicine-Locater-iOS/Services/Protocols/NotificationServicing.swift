//
//  NotificationServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import UserNotifications

@MainActor
protocol NotificationServicing {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestPermission() async -> Bool
    func notify(id: String, title: String, body: String) async
}
