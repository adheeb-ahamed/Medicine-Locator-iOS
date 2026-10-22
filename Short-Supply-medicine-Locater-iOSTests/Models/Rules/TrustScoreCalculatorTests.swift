//
//  TrustScoreCalculatorTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct TrustScoreCalculatorTests {
    let t0 = TestData.t0

    // MARK: Starting points

    @Test func verifiedPharmacyStartsHigh() {
        let response = TestData.response(source: .verifiedPharmacy)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.90)
        #expect(TrustScoreCalculator.level(for: response, at: t0) == .high)
    }

    @Test func onSiteMemberStartsMedium() {
        let response = TestData.response(onSite: true)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.55)
        #expect(TrustScoreCalculator.level(for: response, at: t0) == .medium)
    }

    @Test func remoteMemberStartsLow() {
        let response = TestData.response(onSite: false)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.30)
        #expect(TrustScoreCalculator.level(for: response, at: t0) == .low)
    }

    // MARK: Votes

    @Test func twoConfirmationsMakeItHigh() {
        let response = TestData.response(stillAvailable: 2)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.75)
        #expect(TrustScoreCalculator.level(for: response, at: t0) == .high)
    }

    @Test func confirmationBonusIsCapped() {
        let response = TestData.response(stillAvailable: 10)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.85)   // 0.55 + max 0.30
    }

    @Test func soldOutVotesDoNotLowerTheScore() {
        let response = TestData.response(soldOut: 3)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.55)
    }

    @Test func neverHereReportsLowerTheScore() {
        let response = TestData.response(onSite: false, neverHere: 1)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0.10)
        #expect(TrustScoreCalculator.level(for: response, at: t0) == .hidden)
    }

    @Test func scoreNeverGoesBelowZero() {
        let response = TestData.response(onSite: false, neverHere: 5)
        #expect(TrustScoreCalculator.score(for: response, at: t0) == 0)
    }

    // MARK: Time

    @Test func olderInformationLosesConfidence() {
        let response = TestData.response(lifetimeHours: 6)
        let halfway = t0 + .hours(3)
        #expect(TrustScoreCalculator.score(for: response, at: halfway) == 0.44)   // 0.55 × 0.8
    }

    @Test func expiredResponseScoresZero() {
        let response = TestData.response(source: .verifiedPharmacy, lifetimeHours: 6)
        let afterExpiry = t0 + .hours(7)
        #expect(TrustScoreCalculator.score(for: response, at: afterExpiry) == 0)
        #expect(TrustScoreCalculator.level(for: response, at: afterExpiry) == .hidden)
    }
}
