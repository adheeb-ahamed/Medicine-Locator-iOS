//
//  DirectionViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  DirectionsViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation
import Observation
import CoreLocation

/// In-app directions from my location to one pharmacy.
@MainActor
@Observable
final class DirectionsViewModel {
    enum State {
        case loading
        case route(RouteInfo)
        case straightLine(distance: Double)   // MapKit has no road data → honest fallback
        case locationOff
    }

    let pharmacy: Pharmacy
    var walking = false
    private(set) var state: State = .loading
    private(set) var userCoordinate: CLLocationCoordinate2D?

    private let routeService: RouteServicing
    private let locationService: LocationServicing

    init(pharmacy: Pharmacy, routeService: RouteServicing, locationService: LocationServicing) {
        self.pharmacy = pharmacy
        self.routeService = routeService
        self.locationService = locationService
    }

    // Easy-to-read helpers for the View (and tests)
    var route: RouteInfo? {
        if case .route(let info) = state { return info }
        return nil
    }
    var isStraightLine: Bool {
        if case .straightLine = state { return true }
        return false
    }
    var needsLocation: Bool {
        if case .locationOff = state { return true }
        return false
    }

    func load() async {
        state = .loading

        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: break
        default:
            state = .locationOff
            return
        }

        guard let here = try? await locationService.currentLocation() else {
            state = .locationOff
            return
        }
        userCoordinate = here.coordinate

        do {
            state = .route(try await routeService.route(from: here.coordinate,
                                                        to: pharmacy.coordinate,
                                                        walking: walking))
        } catch {
            state = .straightLine(distance: pharmacy.distance(from: here))
        }
    }
}
