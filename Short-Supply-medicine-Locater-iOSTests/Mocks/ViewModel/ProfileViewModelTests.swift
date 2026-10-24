//
//  ProfileViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct ProfileViewModelTests {

    @Test func totalAndRecentComeFromTheLedger() async {
        let auth = MockAuthService()
        auth.currentUserID = "me"
        let reputation = MockReputationService()
        reputation.entries = [
            ReputationEntry(id: "1", userID: "me", reason: .confirmedOnSite, responseID: "r",
                            requestID: nil, createdAt: TestData.t0),
            ReputationEntry(id: "2", userID: "me", reason: .responseMarkedFound, responseID: "r",
                            requestID: "q", createdAt: TestData.t0 + .hours(1)),
            ReputationEntry(id: "3", userID: "someone-else", reason: .responseMarkedFound, responseID: "r",
                            requestID: "q", createdAt: TestData.t0)
        ]
        let vm = ProfileViewModel(reputationService: reputation, authService: auth)
        await vm.load()

        #expect(vm.total == 35)                    // 10 + 25, not someone else's
        #expect(vm.recent.map(\.id) == ["2", "1"]) // newest first
    }
}