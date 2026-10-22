//
//  TestData.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
@testable import Short_Supply_medicine_Locater_iOS

/// Fixed test data. A fixed date means tests give the same result every run.
enum TestData {
    static let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    static func response(source: AvailabilityResponse.Source = .community,
                         onSite: Bool = true,
                         stillAvailable: Int = 0,
                         soldOut: Int = 0,
                         neverHere: Int = 0,
                         lifetimeHours: Double = 6) -> AvailabilityResponse {
        AvailabilityResponse(
            id: "response-1",
            requestID: "request-1",
            responderID: "user-1",
            pharmacyID: "pharmacy-1",
            pharmacyName: "Test Pharmacy",
            source: source,
            wasOnSite: onSite,
            createdAt: t0,
            expiresAt: t0 + .hours(lifetimeHours),
            stillAvailableCount: stillAvailable,
            soldOutCount: soldOut,
            neverHereCount: neverHere
        )
    }
}
