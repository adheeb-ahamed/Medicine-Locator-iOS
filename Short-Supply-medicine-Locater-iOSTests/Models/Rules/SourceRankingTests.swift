//
//  SourceRankingTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct SourceRankingTests {
    let t0 = TestData.t0

    @Test func sortsMostTrustworthyFirst() {
        let remote   = TestData.response(id: "remote", onSite: false)                 // 0.30
        let onSite   = TestData.response(id: "onsite")                               // 0.55
        let pharmacy = TestData.response(id: "pharmacy", source: .verifiedPharmacy)  // 0.90
        let ranked = SourceRanking.rank([remote, onSite, pharmacy], at: t0)
        #expect(ranked.map(\.id) == ["pharmacy", "onsite", "remote"])
    }

    @Test func hidesExpiredWeakAndClosedReports() {
        let expired = TestData.response(id: "expired", lifetimeHours: 1)
        let weak    = TestData.response(id: "weak", onSite: false, neverHere: 1)   // 0.10 → hidden
        let soldOut = TestData.response(id: "soldout", soldOut: 2)                 // closed
        let good    = TestData.response(id: "good")
        let ranked = SourceRanking.rank([expired, weak, soldOut, good], at: t0 + .hours(2))
        #expect(ranked.map(\.id) == ["good"])
    }
}
