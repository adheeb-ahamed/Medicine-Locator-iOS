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
import MapKit

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
    
    /// The area the map should show: me + the pharmacy + the whole route, with a margin.
    var mapRect: MKMapRect? {
        guard let from = userCoordinate else { return nil }
        var rect = route?.polyline.boundingMapRect ?? .null
        for coordinate in [from, pharmacy.coordinate] {
            rect = rect.union(MKMapRect(origin: MKMapPoint(coordinate), size: MKMapSize(width: 0, height: 0)))
        }
        // 35% margin on each side (at least ~300 m) so pins never sit on the edge.
        let padX = max(rect.size.width * 0.35, 2000)
        let padY = max(rect.size.height * 0.35, 2000)
        return rect.insetBy(dx: -padX, dy: -padY)
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
