//
//  HomeViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct HomeViewModelTests {
    let pharmacies = [
        TestData.pharmacy(id: "middle", latitude: 6.9844),
        TestData.pharmacy(id: "near",   latitude: 6.9444)
    ]

    private func makeSUT(status: CLAuthorizationStatus) -> HomeViewModel {
        let pharmacyService = MockPharmacyService()
        pharmacyService.pharmacies = pharmacies
        return HomeViewModel(pharmacyService: pharmacyService,
                             locationService: MockLocationService(status: status))
    }

    @Test func notAskedYetShowsUnknown() async {
        let vm = makeSUT(status: .notDetermined)
        await vm.load()
        #expect(vm.locationState == .unknown)
        #expect(vm.nearby.isEmpty)
    }

    @Test func deniedShowsDenied() async {
        let vm = makeSUT(status: .denied)
        await vm.load()
        #expect(vm.locationState == .denied)
    }

    @Test func allowedShowsNearestFirst() async {
        let vm = makeSUT(status: .authorizedWhenInUse)
        await vm.load()
        #expect(vm.locationState == .available)
        #expect(vm.nearby.map(\.id) == ["near", "middle"])
    }

    @Test func enablingLocationLoadsNearby() async {
        let vm = makeSUT(status: .notDetermined)
        await vm.enableLocation()
        #expect(vm.locationState == .available)
        #expect(vm.nearby.count == 2)
    }
}
