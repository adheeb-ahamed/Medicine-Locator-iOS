//
//  ReputationPolicyTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct ReputationPolicyTests {

    @Test func pointsMatchTheProposal() {
        #expect(ReputationEvent.confirmedOnSite.points == 10)
        #expect(ReputationEvent.responseMarkedFound.points == 25)
        #expect(ReputationEvent.responseProvedFalse.points == -15)
    }

    @Test func eventsAddUp() {
        var reputation = 0
        reputation = ReputationPolicy.apply(.confirmedOnSite, to: reputation)       // 10
        reputation = ReputationPolicy.apply(.responseMarkedFound, to: reputation)   // 35
        reputation = ReputationPolicy.apply(.responseProvedFalse, to: reputation)   // 20
        #expect(reputation == 20)
    }

    @Test func reputationNeverGoesNegative() {
        #expect(ReputationPolicy.apply(.responseProvedFalse, to: 5) == 0)
    }
}
