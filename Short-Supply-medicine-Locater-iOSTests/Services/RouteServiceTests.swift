//
//  RouteServiceTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  RouteServiceTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import Foundation
import MapKit
@testable import Short_Supply_medicine_Locater_iOS

struct OSRMParsingTests {
    /// A trimmed real-shape OSRM reply (Colombo).
    let sampleJSON = """
    {"code":"Ok","routes":[{"distance":3120.5,"duration":540.2,
      "geometry":{"type":"LineString","coordinates":[[79.85,6.91],[79.86,6.912],[79.88,6.92]]},
      "legs":[{"steps":[
        {"name":"Galle Road","maneuver":{"type":"depart","modifier":"right"}},
        {"name":"Ward Place","maneuver":{"type":"turn","modifier":"left"}},
        {"name":"","maneuver":{"type":"arrive"}}]}]}]}
    """.data(using: .utf8)!

    @Test func readsDistanceTimeAndSteps() throws {
        let info = try OSRMRouteService.routeInfo(from: sampleJSON)
        #expect(info.distance == 3120.5)
        #expect(info.travelTime == 540.2)
        #expect(info.steps == ["Start on Galle Road", "Turn left onto Ward Place", "Arrive at the pharmacy"])
        #expect(info.attribution != nil)
    }

    @Test func longitudeLatitudeOrderIsCorrect() throws {
        let info = try OSRMRouteService.routeInfo(from: sampleJSON)
        var first = CLLocationCoordinate2D()
        info.polyline.getCoordinates(&first, range: NSRange(location: 0, length: 1))
        #expect(abs(first.latitude - 6.91) < 0.0001)     // NOT 79.85
        #expect(abs(first.longitude - 79.85) < 0.0001)
        #expect(info.polyline.pointCount == 3)
    }

    @Test func noRouteThrows() {
        let json = #"{"code":"NoRoute","routes":[]}"#.data(using: .utf8)!
        #expect(throws: RouteError.self) { try OSRMRouteService.routeInfo(from: json) }
    }

    @Test func instructionText() {
        #expect(OSRMRouteService.instruction(type: "turn", modifier: "right", road: "Duplication Road")
                == "Turn right onto Duplication Road")
        #expect(OSRMRouteService.instruction(type: "continue", modifier: nil, road: "")
                == "Continue onto the road")
        #expect(OSRMRouteService.instruction(type: "turn", modifier: "uturn", road: "Galle Road")
                == "Make a U-turn onto Galle Road")
    }
}

@MainActor
struct FallbackRouteServiceTests {
    @Test func usesSecondProviderWhenFirstFails() async throws {
        let apple = MockRouteService(); apple.shouldFail = true
        let osm = MockRouteService()
        let service = FallbackRouteService([apple, osm])

        let info = try await service.route(from: .init(latitude: 6.9, longitude: 79.85),
                                           to: .init(latitude: 6.92, longitude: 79.88),
                                           walking: false)
        #expect(info.distance == 1200)            // came from the second mock
        #expect(osm.askedWalking == false)
    }

    @Test func throwsWhenAllFail() async {
        let a = MockRouteService(); a.shouldFail = true
        let b = MockRouteService(); b.shouldFail = true
        let service = FallbackRouteService([a, b])
        await #expect(throws: RouteError.self) {
            _ = try await service.route(from: .init(latitude: 0, longitude: 0),
                                        to: .init(latitude: 1, longitude: 1),
                                        walking: false)
        }
    }
}
