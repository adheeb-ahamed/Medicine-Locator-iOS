//
//  MapViewModelTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct MapViewModelTests {

    /// User (mock) is at Colombo Fort, latitude 6.9344.
    private func makeSUT(status: CLAuthorizationStatus = .authorizedWhenInUse) -> MapViewModel {
        var hospital = TestData.pharmacy(id: "hospital", latitude: 6.9844)   // ~5.5 km
        hospital.kind = .hospital
        var verified = TestData.pharmacy(id: "verified", latitude: 6.9444)   // ~1.1 km
        verified.isVerified = true
        let far = TestData.pharmacy(id: "far", latitude: 7.2906)             // ~40 km

        let service = MockPharmacyService()
        service.pharmacies = [hospital, verified, far]
        return MapViewModel(pharmacyService: service,
                            locationService: MockLocationService(status: status))
    }

    @Test func chipsFilterThePins() async {
        let vm = makeSUT()
        await vm.load()

        #expect(vm.visiblePharmacies.count == 3)
        vm.filter = .hospitals
        #expect(vm.visiblePharmacies.map(\.id) == ["hospital"])
        vm.filter = .verified
        #expect(vm.visiblePharmacies.map(\.id) == ["verified"])
    }

    @Test func carouselIsNearestFirst() async {
        let vm = makeSUT()
        await vm.load()
        #expect(vm.carouselPharmacies.map(\.id) == ["verified", "hospital", "far"])
    }

    @Test func noLocationMeansNoDistance() async {
        let vm = makeSUT(status: .denied)
        await vm.load()
        #expect(vm.userLocation == nil)
        #expect(vm.distance(to: vm.pharmacies[0]) == nil)
        #expect(vm.carouselPharmacies.count == 3)         // still shows cards
    }
}