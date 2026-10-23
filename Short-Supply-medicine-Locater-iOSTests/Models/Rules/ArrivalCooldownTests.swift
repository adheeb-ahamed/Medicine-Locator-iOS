//
//  ArrivalCooldownTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct ArrivalCooldownTests {
    let t0 = TestData.t0

    @Test func neverNotifiedBeforeMeansNotify() {
        #expect(ArrivalCooldown.shouldNotify(lastNotified: nil, now: t0))
    }

    @Test func withinTwelveHoursStaysQuiet() {
        #expect(!ArrivalCooldown.shouldNotify(lastNotified: t0, now: t0 + .hours(11)))
    }

    @Test func afterTwelveHoursNotifiesAgain() {
        #expect(ArrivalCooldown.shouldNotify(lastNotified: t0, now: t0 + .hours(12)))
    }
}
