//
//  ClosingRuleTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct ClosingRuleTests {

    @Test func noVotesStaysOpen() {
        #expect(ClosingRule.outcome(soldOutVotes: 0, neverHereVotes: 0) == .open)
    }

    @Test func oneSoldOutVoteIsNotEnough() {
        #expect(ClosingRule.outcome(soldOutVotes: 1, neverHereVotes: 0) == .open)
    }

    @Test func twoSoldOutVotesClose() {
        #expect(ClosingRule.outcome(soldOutVotes: 2, neverHereVotes: 0) == .soldOut)
    }

    @Test func pharmacyCanCloseItsOwnPost() {
        #expect(ClosingRule.outcome(soldOutVotes: 0, neverHereVotes: 0, closedByPharmacy: true) == .soldOut)
    }

    @Test func twoNeverHereVotesProveItFalse() {
        #expect(ClosingRule.outcome(soldOutVotes: 0, neverHereVotes: 2) == .provedFalse)
    }

    @Test func conflictingVotesFavourTheResponder() {
        #expect(ClosingRule.outcome(soldOutVotes: 2, neverHereVotes: 2) == .soldOut)
    }

    @Test func readsCountsFromAResponse() {
        let response = TestData.response(soldOut: 2)
        #expect(ClosingRule.outcome(for: response) == .soldOut)
    }
}
