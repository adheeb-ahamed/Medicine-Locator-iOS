//
//  VoteRulesTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct VoteRulesTests {
    let t0 = TestData.t0

    @Test func stillAvailableCountsAndExtendsExpiry() {
        let response = TestData.response()                     // 6 h lifetime
        let outcome = VoteRules.apply(.stillAvailable, by: "voter", to: response, at: t0)
        #expect(outcome.updatedResponse.stillAvailableCount == 1)
        #expect(outcome.updatedResponse.expiresAt == t0 + .hours(8))
    }

    @Test func extensionNeverPassesTwelveHours() {
        let response = TestData.response(stillAvailable: 5, lifetimeHours: 12)
        let outcome = VoteRules.apply(.stillAvailable, by: "voter", to: response, at: t0)
        #expect(outcome.updatedResponse.expiresAt == t0 + .hours(12))
    }

    @Test func soldOutDoesNotExtend() {
        let response = TestData.response()
        let outcome = VoteRules.apply(.soldOut, by: "voter", to: response, at: t0)
        #expect(outcome.updatedResponse.soldOutCount == 1)
        #expect(outcome.updatedResponse.expiresAt == response.expiresAt)
    }

    @Test func voterAlwaysEarnsTenWithAFixedID() {
        let outcome = VoteRules.apply(.soldOut, by: "voter", to: TestData.response(), at: t0)
        #expect(outcome.reputationEntries.count == 1)
        #expect(outcome.reputationEntries[0].id == "vote_response-1_voter")
        #expect(outcome.reputationEntries[0].points == 10)
        #expect(outcome.confirmation.id == "voter")
    }

    @Test func secondNeverHerePenalisesTheResponder() {
        let response = TestData.response(neverHere: 1)
        let outcome = VoteRules.apply(.neverHere, by: "voter", to: response, at: t0)
        let penalty = outcome.reputationEntries.first { $0.reason == .responseProvedFalse }
        #expect(penalty?.userID == "user-1")                 // the responder in TestData
        #expect(penalty?.points == -15)
        #expect(penalty?.id == "false_response-1")
    }

    @Test func firstNeverHereDoesNotPenaliseYet() {
        let outcome = VoteRules.apply(.neverHere, by: "voter", to: TestData.response(), at: t0)
        #expect(outcome.reputationEntries.allSatisfy { $0.reason == .confirmedOnSite })
    }
}
