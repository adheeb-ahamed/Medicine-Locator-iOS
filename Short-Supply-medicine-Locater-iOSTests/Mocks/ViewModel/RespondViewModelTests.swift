//
//  RespondViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct RespondViewModelTests {

    private func makeSUT(requestOwner: String = "someone-else",
                         at location: CLLocation) -> (RespondViewModel, MockResponseService) {
        let pharmacies = MockPharmacyService()
        pharmacies.pharmacies = [TestData.pharmacy(id: "p1", latitude: 6.9344, longitude: 79.8428)]

        let locationService = MockLocationService(status: .authorizedWhenInUse)
        locationService.location = location

        let auth = MockAuthService()
        auth.currentUserID = "helper"

        let responses = MockResponseService()
        let vm = RespondViewModel(request: TestData.request(ownerID: requestOwner),
                                  responseService: responses,
                                  pharmacyService: pharmacies,
                                  locationService: locationService,
                                  authService: auth)
        return (vm, responses)
    }

    @Test func standingAtPharmacyPreselectsItAndCountsAsOnSite() async {
        let (vm, _) = makeSUT(at: CLLocation(latitude: 6.9345, longitude: 79.8428))   // ~11 m away
        await vm.load()
        #expect(vm.selected?.id == "p1")
        #expect(vm.isOnSite)
    }

    @Test func farAwayIsNotOnSite() async {
        let (vm, _) = makeSUT(at: CLLocation(latitude: 6.9444, longitude: 79.8428))   // ~1.1 km
        await vm.load()
        vm.selected = vm.options.first
        #expect(!vm.isOnSite)
    }

    @Test func cannotAnswerOwnRequest() async {
        let (vm, responses) = makeSUT(requestOwner: "helper", at: CLLocation(latitude: 6.9345, longitude: 79.8428))
        await vm.load()
        #expect(vm.isOwnRequest)
        #expect(!vm.canSend)
        await vm.send()
        #expect(responses.responses.isEmpty)
    }

    @Test func sendingCreatesASixHourCommunityReport() async throws {
        let (vm, responses) = makeSUT(at: CLLocation(latitude: 6.9345, longitude: 79.8428))
        await vm.load()
        await vm.send()

        let sent = try #require(responses.responses.first)
        #expect(sent.responderID == "helper")
        #expect(sent.medicineKey == "imatinib")
        #expect(sent.wasOnSite)
        #expect(sent.expiresAt.timeIntervalSince(sent.createdAt) == .hours(6))
        #expect(vm.didSend)
    }
}
