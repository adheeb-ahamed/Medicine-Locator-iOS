//
//  OSRMRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//


//
//  OSRMRouteService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Free road routing from OpenStreetMap (OSRM), used where Apple Maps has no directions (Sri Lanka).
//  No API key or payment needed.

import Foundation
import MapKit

@MainActor
final class OSRMRouteService: RouteServicing {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func route(from: CLLocationCoordinate2D,
               to: CLLocationCoordinate2D,
               walking: Bool) async throws -> RouteInfo {
        // Separate public servers for car and foot routing.
        let profile = walking ? "routed-foot" : "routed-car"
        // OSRM wants LONGITUDE first, then latitude.
        let points = "\(from.longitude),\(from.latitude);\(to.longitude),\(to.latitude)"
        guard let url = URL(string:
            "https://routing.openstreetmap.de/\(profile)/route/v1/driving/\(points)?overview=full&geometries=geojson&steps=true")
        else { throw RouteError.noRoute }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("MedicineLocator-iOS (student project)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw RouteError.noRoute }
        return try Self.routeInfo(from: data)
    }

    // MARK: - Parsing (static + nonisolated so unit tests can call it with sample JSON)

    nonisolated static func routeInfo(from data: Data) throws -> RouteInfo {
        let decoded = try JSONDecoder().decode(OSRMResponse.self, from: data)
        guard decoded.code == "Ok", let route = decoded.routes?.first else { throw RouteError.noRoute }

        // GeoJSON gives [longitude, latitude] pairs → turn them into map coordinates.
        let coordinates = route.geometry.coordinates.compactMap { pair -> CLLocationCoordinate2D? in
            guard pair.count >= 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0])
        }
        guard coordinates.count >= 2 else { throw RouteError.noRoute }

        let steps = route.legs
            .flatMap(\.steps)
            .map { instruction(type: $0.maneuver.type, modifier: $0.maneuver.modifier, road: $0.name) }

        return RouteInfo(polyline: MKPolyline(coordinates: coordinates, count: coordinates.count),
                         distance: route.distance,
                         travelTime: route.duration,
                         steps: steps,
                         attribution: "Route © OpenStreetMap contributors")
    }

    /// OSRM gives a manoeuvre ("turn", "left") — we turn it into a sentence.
    nonisolated static func instruction(type: String, modifier: String?, road: String) -> String {
        let road = road.isEmpty ? "the road" : road
        switch type {
        case "depart":
            return "Start on \(road)"
        case "arrive":
            return "Arrive at the pharmacy"
        case "roundabout", "rotary", "roundabout turn":
            return "Take the roundabout onto \(road)"
        default:
            switch modifier ?? "straight" {
            case "straight": return "Continue onto \(road)"
            case "uturn":    return "Make a U-turn onto \(road)"
            default:         return "Turn \(modifier ?? "") onto \(road)"
            }
        }
    }
}

/// The parts of OSRM's JSON reply that we use.
private struct OSRMResponse: Decodable {
    let code: String
    let routes: [Route]?

    struct Route: Decodable {
        let distance: Double
        let duration: Double
        let geometry: Geometry
        let legs: [Leg]
    }
    struct Geometry: Decodable { let coordinates: [[Double]] }
    struct Leg: Decodable { let steps: [Step] }
    struct Step: Decodable {
        let name: String
        let maneuver: Maneuver
    }
    struct Maneuver: Decodable {
        let type: String
        let modifier: String?
    }
}