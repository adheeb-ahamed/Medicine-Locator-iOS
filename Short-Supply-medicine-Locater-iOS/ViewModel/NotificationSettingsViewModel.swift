//
//  NotificationSettingsViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation
import UserNotifications
import CoreLocation

/// The Notifications settings screen.
@MainActor
@Observable
final class NotificationSettingsViewModel {
    /// Saved on every change; turning arrivals on/off starts/stops monitoring.
    var preferences: NotificationPreferences {
        didSet {
            preferences.save(to: defaults)
            if preferences.arrivals != oldValue.arrivals {
                Task { await arrivals.resumeIfEnabled() }
            }
        }
    }

    private(set) var notificationStatus: UNAuthorizationStatus = .notDetermined
    private(set) var locationStatus: CLAuthorizationStatus = .notDetermined

    private let notificationService: NotificationServicing
    private let locationService: LocationServicing
    private let arrivals: ArrivalMonitoring
    private let defaults: UserDefaults

    init(notificationService: NotificationServicing,
         locationService: LocationServicing,
         arrivals: ArrivalMonitoring,
         defaults: UserDefaults = .standard) {
        self.notificationService = notificationService
        self.locationService = locationService
        self.arrivals = arrivals
        self.defaults = defaults
        self.preferences = NotificationPreferences.load(from: defaults)
    }

    var notificationsAllowed: Bool { notificationStatus == .authorized }
    var hasAlwaysLocation: Bool { locationStatus == .authorizedAlways }

    /// Re-read permissions (call when the screen appears and when returning from Settings).
    func refresh() async {
        notificationStatus = await notificationService.authorizationStatus()
        locationStatus = locationService.authorizationStatus
        await arrivals.resumeIfEnabled()
    }

    func enableNotifications() async {
        _ = await notificationService.requestPermission()
        await refresh()
    }

    func requestAlwaysLocation() {
        locationService.requestAlwaysPermission()
    }
}
