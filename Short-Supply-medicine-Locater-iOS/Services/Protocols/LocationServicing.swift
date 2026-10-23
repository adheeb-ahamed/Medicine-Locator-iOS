//
//  LocationServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreLocation

/// Asks for location permission and gets the current position.
@MainActor
protocol LocationServicing {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestPermission() async -> CLAuthorizationStatus
    func currentLocation() async throws -> CLLocation
}

enum LocationError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        "Location access is off for Medicine Locator."
    }
}
