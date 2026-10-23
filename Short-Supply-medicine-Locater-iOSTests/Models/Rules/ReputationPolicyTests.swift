//
//  ReputationPolicyTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
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
    
    @Test func ledgerTotalAppliesEntriesInDateOrderWithFloor() {
        func entry(_ reason: ReputationEvent, _ hours: Double) -> ReputationEntry {
            ReputationEntry(id: UUID().uuidString, userID: "u", reason: reason,
                            responseID: "r", requestID: nil, createdAt: TestData.t0 + .hours(hours))
        }
        // Order in the array is scrambled on purpose:
        let entries = [entry(.confirmedOnSite, 2),      // then +10 → 10
                       entry(.responseProvedFalse, 1),  // first −15 → 0 (floor)
                       entry(.responseMarkedFound, 3)]  // then +25 → 35
        #expect(ReputationPolicy.total(of: entries) == 35)
    }
}
