//
//  RouteServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  RouteServicing.swift
//  Short-Supply-medicine-Locater-iOS
//

import CoreLocation

/// Calculates a route between two points. Protocol so tests can use a mock.
@MainActor
protocol RouteServicing {
    func route(from: CLLocationCoordinate2D,
               to: CLLocationCoordinate2D,
               walking: Bool) async throws -> RouteInfo
}
