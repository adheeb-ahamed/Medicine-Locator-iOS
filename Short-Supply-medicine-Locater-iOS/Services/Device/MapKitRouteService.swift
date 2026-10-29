//
//  MapKitRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  MapKitRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//

import MapKit

enum RouteError: LocalizedError {
    case noRoute
    var errorDescription: String? { "No route found." }
}

/// Real routes from Apple's MapKit directions (MKDirections). No other app is opened.
@MainActor
final class MapKitRouteService: RouteServicing {
    func route(from: CLLocationCoordinate2D,
               to: CLLocationCoordinate2D,
               walking: Bool) async throws -> RouteInfo {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = walking ? .walking : .automobile

        let response = try await MKDirections(request: request).calculate()
        guard let route = response.routes.first else { throw RouteError.noRoute }

        return RouteInfo(polyline: route.polyline,
                         distance: route.distance,
                         travelTime: route.expectedTravelTime,
                         steps: route.steps.map(\.instructions).filter { !$0.isEmpty })
    }
}
