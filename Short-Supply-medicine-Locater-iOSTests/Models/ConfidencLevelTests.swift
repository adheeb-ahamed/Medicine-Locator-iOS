//
//  ConfidencLevelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct ConfidenceLevelTests {

    @Test(arguments: zip(
        [1.0,   0.70,  0.69,    0.40,    0.39, 0.15, 0.14,    0.0],
        [ConfidenceLevel.high, .high, .medium, .medium, .low, .low, .hidden, .hidden]
    ))
    func scoreMapsToCorrectLevel(score: Double, expected: ConfidenceLevel) {
        #expect(ConfidenceLevel(score: score) == expected)
    }

    @Test func hiddenIsNotVisible() {
        #expect(!ConfidenceLevel.hidden.isVisible)
        #expect(ConfidenceLevel.low.isVisible)
    }
}
