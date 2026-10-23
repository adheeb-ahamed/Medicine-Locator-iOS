//
//  NewRequestViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct NewRequestViewModelTests {

    private func makeSUT(name: String = "Imatinib") -> (NewRequestViewModel, MockRequestService) {
        let pharmacies = MockPharmacyService()
        pharmacies.pharmacies = [
            TestData.pharmacy(id: "a", district: "Colombo", latitude: 6.9344),
            TestData.pharmacy(id: "b", district: "Gampaha", latitude: 7.1344)
        ]
        let auth = MockAuthService()
        auth.currentUserID = "anon-user"
        let requests = MockRequestService()
        let vm = NewRequestViewModel(medicineName: name,
                                     requestService: requests,
                                     pharmacyService: pharmacies,
                                     locationService: MockLocationService(status: .authorizedWhenInUse),
                                     authService: auth)
        return (vm, requests)
    }

    @Test func preselectsTheNearestDistrict() async {
        let (vm, _) = makeSUT()
        await vm.load()
        #expect(vm.districts == ["Colombo", "Gampaha"])
        #expect(vm.selectedDistrict == "Colombo")
    }

    @Test func controlledMedicineCannotBePosted() async {
        let (vm, requests) = makeSUT(name: "Morphine")
        await vm.load()
        #expect(vm.isControlled)
        #expect(!vm.canPost)
        await vm.post()
        #expect(requests.stored.isEmpty)
    }

    @Test func postingCreatesAnonymousSevenDayRequest() async throws {
        let (vm, requests) = makeSUT()
        await vm.load()
        await vm.post()

        let posted = try #require(requests.stored.first)
        #expect(posted.ownerID == "anon-user")
        #expect(posted.areaName == "Colombo")
        #expect(posted.status == .open)
        #expect(posted.expiresAt.timeIntervalSince(posted.createdAt) == .days(7))
        #expect(vm.postedRequest?.id == posted.id)
    }
}
