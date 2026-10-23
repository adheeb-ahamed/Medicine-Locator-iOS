//
//  RegionMonitorService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreLocation
import UserNotifications

@MainActor
protocol ArrivalMonitoring {
    func resumeIfEnabled() async
    func stop() async
}

/// "You've arrived at a pharmacy" prompts using iOS 17's CLMonitor.
@MainActor
final class RegionMonitorService: ArrivalMonitoring {
    private static let monitorName = "PharmacyArrivals"
    private static let lastNotifiedKey = "arrivalLastNotified"
    private static let maxRegions = 20                     // iOS limit per app

    private var monitor: CLMonitor?
    private var eventsTask: Task<Void, Never>?
    private var pharmaciesByID: [String: Pharmacy] = [:]

    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing
    private let notificationService: NotificationServicing
    private let defaults: UserDefaults

    init(pharmacyService: PharmacyServicing,
         locationService: LocationServicing,
         notificationService: NotificationServicing,
         defaults: UserDefaults = .standard) {
        self.pharmacyService = pharmacyService
        self.locationService = locationService
        self.notificationService = notificationService
        self.defaults = defaults
    }

    /// Start watching the 20 nearest pharmacies — only if the user opted in and gave permission.
    func resumeIfEnabled() async {
        let preferences = NotificationPreferences.load(from: defaults)
        guard preferences.arrivals,
              locationService.authorizationStatus == .authorizedAlways,
              await notificationService.authorizationStatus() == .authorized,
              let here = try? await locationService.currentLocation(),
              let pharmacies = try? pharmacyService.loadPharmacies() else {
            await stop()
            return
        }

        let nearest = PharmacyFinder.nearby(pharmacies, from: here, within: .infinity)
            .prefix(Self.maxRegions)
            .map(\.pharmacy)
        await watch(Array(nearest))
    }

    /// Remove every watched circle.
    func stop() async {
        guard let monitor else { return }
        for id in await monitor.identifiers {
            await monitor.remove(id)
        }
    }

    // MARK: - Private

    private func watch(_ pharmacies: [Pharmacy]) async {
        let monitor = await currentMonitor()

        // Replace the old set of circles with the new nearest ones.
        for id in await monitor.identifiers {
            await monitor.remove(id)
        }
        pharmaciesByID = Dictionary(pharmacies.map { ($0.id, $0) },
                                    uniquingKeysWith: { first, _ in first })

        for pharmacy in pharmacies {
            let circle = CLMonitor.CircularGeographicCondition(center: pharmacy.coordinate,
                                                               radius: Constants.Location.arrivalRadius)
            await monitor.add(circle, identifier: pharmacy.id, assuming: .unsatisfied)
        }
    }

    /// Create the monitor once and keep listening to its events.
    private func currentMonitor() async -> CLMonitor {
        if let monitor { return monitor }

        let monitor = await CLMonitor(Self.monitorName)
        self.monitor = monitor

        eventsTask = Task { [weak self] in
            do {
                for try await event in await monitor.events where event.state == .satisfied {
                    await self?.handleArrival(at: event.identifier)
                }
            } catch {
                // Monitoring stopped (e.g. permission removed) — nothing to do.
            }
        }
        return monitor
    }

    private func handleArrival(at pharmacyID: String) async {
        guard let pharmacy = pharmaciesByID[pharmacyID] else { return }
        let preferences = NotificationPreferences.load(from: defaults)
        guard preferences.arrivals else { return }

        var history = defaults.dictionary(forKey: Self.lastNotifiedKey) as? [String: Date] ?? [:]
        guard ArrivalCooldown.shouldNotify(lastNotified: history[pharmacyID]) else { return }

        let text = NotificationText.arrival(pharmacyName: pharmacy.name, discreet: preferences.discreet)
        await notificationService.notify(id: "arrival-\(pharmacyID)", title: text.title, body: text.body)

        history[pharmacyID] = .now
        defaults.set(history, forKey: Self.lastNotifiedKey)
    }
}
