//
//  DirectionViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  DirectionsViewModelTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import MapKit
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockRouteService: RouteServicing {
    var shouldFail = false
    private(set) var askedWalking: Bool?

    func route(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D,
               walking: Bool) async throws -> RouteInfo {
        askedWalking = walking
        if shouldFail { throw RouteError.noRoute }
        let coordinates = [from, to]
        return RouteInfo(polyline: MKPolyline(coordinates: coordinates, count: coordinates.count),
                         distance: 1200, travelTime: 300, steps: ["Turn left"])
    }
}

@MainActor
struct DirectionsViewModelTests {
    private func makeSUT(status: CLAuthorizationStatus = .authorizedWhenInUse,
                         fail: Bool = false) -> (DirectionsViewModel, MockRouteService) {
        let routes = MockRouteService()
        routes.shouldFail = fail
        let vm = DirectionsViewModel(pharmacy: TestData.pharmacy(),
                                     routeService: routes,
                                     locationService: MockLocationService(status: status))
        return (vm, routes)
    }

    @Test func showsRouteWhenMapKitFindsOne() async {
        let (vm, _) = makeSUT()
        await vm.load()
        #expect(vm.route?.distance == 1200)
    }

    @Test func fallsBackToStraightLine() async {
        let (vm, _) = makeSUT(fail: true)
        await vm.load()
        #expect(vm.isStraightLine)
    }

    @Test func asksForLocationWhenOff() async {
        let (vm, _) = makeSUT(status: .denied)
        await vm.load()
        #expect(vm.needsLocation)
    }

    @Test func walkingModeIsPassedToMapKit() async {
        let (vm, routes) = makeSUT()
        vm.walking = true
        await vm.load()
        #expect(routes.askedWalking == true)
    }
    
    @Test func mapRectContainsMeAndThePharmacy() async throws {
        let (vm, _) = makeSUT()
        await vm.load()
        let rect = try #require(vm.mapRect)
        #expect(rect.contains(MKMapPoint(vm.pharmacy.coordinate)))
        #expect(rect.contains(MKMapPoint(try #require(vm.userCoordinate))))
    }
}


