//
//  FallbackRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//


//
//  FallbackRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//

import CoreLocation

/// Tries each route provider in order and returns the first one that works.
/// Apple Maps first (best where available), then OpenStreetMap (covers Sri Lanka).
@MainActor
final class FallbackRouteService: RouteServicing {
    private let providers: [RouteServicing]

    init(_ providers: [RouteServicing]) {
        self.providers = providers
    }

    func route(from: CLLocationCoordinate2D,
               to: CLLocationCoordinate2D,
               walking: Bool) async throws -> RouteInfo {
        var lastError: Error = RouteError.noRoute
        for provider in providers {
            do {
                return try await provider.route(from: from, to: to, walking: walking)
            } catch {
                lastError = error          // try the next one
            }
        }
        throw lastError                    // all failed → ViewModel shows the straight line
    }
}