//
//  LocationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreLocation

/// Wraps CLLocationManager so the rest of the app can just `await` a location.
@MainActor
final class LocationService: NSObject, LocationServicing {
    private let manager = CLLocationManager()

    // Everyone currently waiting for an answer.
    private var permissionWaiters: [CheckedContinuation<CLAuthorizationStatus, Never>] = []
    private var locationWaiters: [CheckedContinuation<CLLocation, Error>] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func requestPermission() async -> CLAuthorizationStatus {
        // Already decided? Just return the answer.
        guard manager.authorizationStatus == .notDetermined else {
            return manager.authorizationStatus
        }
        // Otherwise show the iOS permission popup and wait for the user.
        return await withCheckedContinuation { continuation in
            permissionWaiters.append(continuation)
            manager.requestWhenInUseAuthorization()
        }
    }

    func currentLocation() async throws -> CLLocation {
        let status = await requestPermission()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationError.permissionDenied
        }
        return try await withCheckedThrowingContinuation { continuation in
            locationWaiters.append(continuation)
            // Only ask GPS once, even if several screens are waiting.
            if locationWaiters.count == 1 {
                manager.requestLocation()
            }
        }
    }
    
    /// Ask to upgrade from "While Using" to "Always" (needed for arrival prompts).
    /// iOS shows this prompt at most once; after that the user must use Settings.
    func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }

    // MARK: - Hand the answer to everyone waiting

    fileprivate func finishPermission(_ status: CLAuthorizationStatus) {
        let waiters = permissionWaiters
        permissionWaiters = []
        waiters.forEach { $0.resume(returning: status) }
    }

    fileprivate func finishLocation(_ result: Result<CLLocation, Error>) {
        let waiters = locationWaiters
        locationWaiters = []
        waiters.forEach { $0.resume(with: result) }
    }
}

// MARK: - CLLocationManagerDelegate (Apple calls these)

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            let status = self.manager.authorizationStatus
            guard status != .notDetermined else { return }
            finishPermission(status)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated {
            guard let location = locations.last else { return }
            finishLocation(.success(location))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        MainActor.assumeIsolated {
            finishLocation(.failure(error))
        }
    }
}
