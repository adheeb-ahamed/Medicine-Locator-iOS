//
//  OnSiteConfirmModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct OnSiteConfirmViewModelTests {
    let pharmacy = TestData.pharmacy(id: "pharmacy-1", latitude: 6.9344, longitude: 79.8428)

    private func makeSUT(userID: String = "voter",
                         at location: CLLocation) -> (OnSiteConfirmViewModel, MockResponseService) {
        let response = TestData.response(createdAt: .now)
        let responses = MockResponseService()
        responses.responses = [response]

        let locationService = MockLocationService(status: .authorizedWhenInUse)
        locationService.location = location

        let auth = MockAuthService()
        auth.currentUserID = userID

        let vm = OnSiteConfirmViewModel(response: response, pharmacy: pharmacy,
                                        responseService: responses,
                                        locationService: locationService,
                                        authService: auth)
        return (vm, responses)
    }

    let atPharmacy = CLLocation(latitude: 6.9345, longitude: 79.8428)
    let farAway    = CLLocation(latitude: 6.9444, longitude: 79.8428)

    @Test func cannotVoteOnOwnReport() async {
        let (vm, _) = makeSUT(userID: "user-1", at: atPharmacy)     // user-1 wrote the report
        await vm.check()
        #expect(vm.state == .ownResponse)
    }

    @Test func farAwayCannotVote() async {
        let (vm, _) = makeSUT(at: farAway)
        await vm.check()
        if case .tooFar = vm.state { } else { Issue.record("Expected tooFar, got \(vm.state)") }
    }

    @Test func onSiteVoteIsRecordedOnce() async {
        let (vm, responses) = makeSUT(at: atPharmacy)
        await vm.check()
        guard case .ready(let distance) = vm.state else {
            Issue.record("Expected ready, got \(vm.state)")
            return
        }
        #expect(distance < 100)

        await vm.vote(.stillAvailable)
        #expect(vm.state == .done(.stillAvailable))
        #expect(responses.responses[0].stillAvailableCount == 1)

        await vm.check()                                   // open the screen again
        #expect(vm.state == .alreadyVoted)
    }
}
