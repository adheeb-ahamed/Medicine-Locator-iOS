//
//  ExpiryPolicyTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct ExpiryPolicyTests {
    let t0 = TestData.t0

    @Test func requestsLastSevenDays() {
        #expect(ExpiryPolicy.requestExpiry(from: t0) == t0 + .days(7))
    }

    @Test(arguments: zip([0, 1, 2, 3, 10],
                         [6.0, 8.0, 10.0, 12.0, 12.0]))
    func communityResponseExtendsUpToTwelveHours(confirmations: Int, expectedHours: Double) {
        let expiry = ExpiryPolicy.communityResponseExpiry(createdAt: t0,
                                                          onSiteConfirmations: confirmations)
        #expect(expiry == t0 + .hours(expectedHours))
    }

    @Test(arguments: PharmacyPostDuration.allCases)
    func pharmacyChoosesDuration(duration: PharmacyPostDuration) {
        let expiry = ExpiryPolicy.pharmacyPostExpiry(createdAt: t0, duration: duration)
        #expect(expiry == t0 + .hours(Double(duration.rawValue)))
    }
}
