//
//  FormattersTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct FormattersTests {
    @Test(arguments: zip([850.0, 999.4, 1_234.0, 10_000.0],
                         ["850 m", "999 m", "1.2 km", "10.0 km"]))
    func distanceText(meters: Double, expected: String) {
        #expect(Formatters.distance(meters) == expected)
    }

    @Test func timeLeftText() {
    let now = Date(timeIntervalSince1970: 0)
    #expect(Formatters.timeLeft(until: now + 35 * 60, from: now) == "35m left")
    #expect(Formatters.timeLeft(until: now + 4 * 3600 + 120, from: now) == "4h left")
    #expect(Formatters.timeLeft(until: now - 60, from: now) == "Expired")
    }
}
