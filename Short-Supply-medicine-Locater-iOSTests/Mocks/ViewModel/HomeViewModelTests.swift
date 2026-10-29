//
//  HomeViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  HomeViewModelTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct HomeViewModelTests {
    let pharmacies = [
        TestData.pharmacy(id: "middle", latitude: 6.9844),
        TestData.pharmacy(id: "near",   latitude: 6.9444)
    ]

    private func makeSUT(status: CLAuthorizationStatus,
                         requests: [MedicineRequest] = []) -> HomeViewModel {
        let pharmacyService = MockPharmacyService()
        pharmacyService.pharmacies = pharmacies
        let requestService = MockRequestService()
        requestService.stored = requests
        let auth = MockAuthService()
        auth.currentUserID = "anon-user"
        return HomeViewModel(pharmacyService: pharmacyService,
                             locationService: MockLocationService(status: status),
                             requestService: requestService,
                             authService: auth)
    }

    // MARK: Location (same as before)

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

    // MARK: New in UI-3

    @Test func myRequestsOnlyShowsMyOpenOnes() async {
        let vm = makeSUT(status: .notDetermined, requests: [
            TestData.request(id: "mine"),
            TestData.request(id: "someone-else", ownerID: "other-user"),
            TestData.request(id: "already-found", status: .found)
        ])
        await vm.load()
        #expect(vm.myActiveRequests.map(\.id) == ["mine"])   // works even without location
    }

    @Test func helpCountExcludesMyOwnRequests() async {
        let vm = makeSUT(status: .authorizedWhenInUse, requests: [
            TestData.request(id: "mine"),
            TestData.request(id: "neighbour", ownerID: "other-user")
        ])
        await vm.load()
        #expect(vm.helpNearbyCount == 1)
    }

    @Test func greetingChangesWithTimeOfDay() {
        let vm = makeSUT(status: .notDetermined)
        let calendar = Calendar.current
        func at(_ hour: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: .now)!
        }
        #expect(vm.greeting(at: at(9))  == "Good morning")
        #expect(vm.greeting(at: at(14)) == "Good afternoon")
        #expect(vm.greeting(at: at(20)) == "Good evening")
    }
}