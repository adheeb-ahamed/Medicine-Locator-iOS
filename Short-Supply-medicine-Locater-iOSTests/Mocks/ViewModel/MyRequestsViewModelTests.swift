//
//  MyRequestsViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct MyRequestsViewModelTests {

    private func makeSUT() -> (MyRequestsViewModel, MockRequestService) {
        let auth = MockAuthService()
        auth.currentUserID = "anon-user"
        let requests = MockRequestService()
        requests.stored = [
            TestData.request(id: "active"),
            TestData.request(id: "expired", expiresAt: .now - .hours(1)),
            TestData.request(id: "someone-else", ownerID: "other-user")
        ]
        return (MyRequestsViewModel(requestService: requests, authService: auth), requests)
    }

    @Test func splitsActiveAndPastAndOnlyShowsMine() async {
        let (vm, _) = makeSUT()
        await vm.load()
        #expect(vm.active.map(\.id) == ["active"])
        #expect(vm.past.map(\.id) == ["expired"])
    }

    @Test func markingFoundMovesToPast() async {
        let (vm, requests) = makeSUT()
        await vm.load()
        await vm.markFound(vm.active[0], response: TestData.response(id: "response-1"))
        #expect(vm.active.isEmpty)
        #expect(requests.stored[0].foundResponseID == "response-1")
    }

    @Test func renewingAnExpiredRequestReopensIt() async {
        let (vm, _) = makeSUT()
        await vm.load()
        await vm.renew(vm.past[0])
        #expect(vm.active.count == 2)
    }

    @Test func answerCountOnlyCountsActiveRequests() async {
    let (vm, requests) = makeSUT()
    requests.stored[0].responseCount = 3   // "active"
    requests.stored[1].responseCount = 5   // "expired" — must not count
    await vm.load()
    #expect(vm.activeAnswerCount == 3)
    }
}
