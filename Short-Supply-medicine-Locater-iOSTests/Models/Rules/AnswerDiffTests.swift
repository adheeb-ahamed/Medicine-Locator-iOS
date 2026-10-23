//
//  AnswerDiffTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct AnswerDiffTests {
    let a = TestData.response(id: "a")
    let b = TestData.response(id: "b")

    @Test func firstCheckRemembersButDoesNotNotify() {
        let result = AnswerDiff.compare(current: [a, b], seen: nil)
        #expect(result.toNotify.isEmpty)
        #expect(result.updatedSeen == ["a", "b"])
    }

    @Test func onlyNewAnswersAreNotified() {
        let result = AnswerDiff.compare(current: [a, b], seen: ["a"])
        #expect(result.toNotify.map(\.id) == ["b"])
        #expect(result.updatedSeen == ["a", "b"])
    }

    @Test func nothingNewMeansNoNotification() {
        let result = AnswerDiff.compare(current: [a], seen: ["a"])
        #expect(result.toNotify.isEmpty)
    }
}
