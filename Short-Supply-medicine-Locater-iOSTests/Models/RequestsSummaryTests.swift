//
//  RequestsSummaryTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  RequestsSummaryTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct RequestsSummaryTests {
    let now = Date(timeIntervalSince1970: 1_800_000_000)   // fixed time

    /// Helper: an open request with some answers.
    private func request(_ id: String, status: MedicineRequest.Status = .open,
                         answers: Int = 0) -> MedicineRequest {
        var request = TestData.request(id: id, status: status, expiresAt: now + .days(7))
        request.responseCount = answers
        return request
    }

    @Test func countsOnlyOpenRequests() {
        let summary = RequestsSummary.make(from: [request("a", answers: 2),
                                                  request("b", answers: 1),
                                                  request("c", status: .found, answers: 5)],
                                           now: now)
        #expect(summary.activeCount == 2)     // the found one is not counted
        #expect(summary.answerCount == 3)     // 2 + 1, not + 5
    }

    @Test func expiredRequestIsNotCounted() {
        var old = request("old")
        old.expiresAt = now - .hours(1)
        #expect(RequestsSummary.make(from: [old], now: now).activeCount == 0)
    }

    @Test func discreetNeverSaysTheMedicine() {
        let summary = RequestsSummary.make(from: [request("a", answers: 2), request("b", answers: 1)], now: now)
        let text = summary.spokenText(discreet: true)
        #expect(text == "You have 2 open requests with 3 answers.")
        #expect(!text.contains("Imatinib"))
    }

    @Test func notDiscreetSaysNamesAndUsesSingular() {
        let summary = RequestsSummary.make(from: [request("a", answers: 1)], now: now)
        #expect(summary.spokenText(discreet: false)
                == "You have 1 open request with 1 answer. Looking for: Imatinib 400 mg.")
    }

    @Test func noRequests() {
        let summary = RequestsSummary.make(from: [], now: now)
        #expect(summary.spokenText(discreet: true) == "You have no open requests.")
    }

    @Test func storeSavesLoadsAndClears() throws {
        let suite = "RequestsSummaryTests"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)        // start empty
        let store = RequestsSummaryStore(defaults: defaults)

        #expect(store.load() == nil)
        let summary = RequestsSummary.make(from: [request("a", answers: 1)], now: now)
        store.save(summary)
        #expect(store.load() == summary)                       // JSON round trip
        store.clear()
        #expect(store.load() == nil)
    }
    
    @Test func sameContentIgnoresTheTime() {
        let a = RequestsSummary.make(from: [request("a", answers: 1)], now: now)
        var b = a
        b.updatedAt = now + .hours(1)                 // only the time changed
        #expect(a.hasSameContent(as: b))              // → don't refresh the widget
    }

    @Test func newAnswerIsAChange() {
        let a = RequestsSummary.make(from: [request("a", answers: 1)], now: now)
        var b = a
        b.answerCount = 2
        #expect(!a.hasSameContent(as: b))             // → refresh the widget
        #expect(!a.hasSameContent(as: nil))           // nothing saved before → refresh
    }
}
