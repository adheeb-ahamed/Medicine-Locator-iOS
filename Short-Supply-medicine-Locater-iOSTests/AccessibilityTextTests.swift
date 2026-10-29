//
//  AccessibilityTextTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  AccessibilityTextTests.swift
//  Short-Supply-medicine-Locater-iOS
//

import Testing
import Foundation

@testable import Short_Supply_medicine_Locater_iOS

/// Checks the sentences VoiceOver reads, so a later change can't silently break them.
struct AccessibilityTextTests {
    let now = Date(timeIntervalSince1970: 0)   // fixed time so tests never depend on the clock

    // Includes out-of-range scores (1.4 and -0.3) to prove clamping works.
    @Test(arguments: zip([0.82, 0.55, 0.20, 1.4, -0.3],
                         ["High confidence, 82 out of 100",
                          "Medium confidence, 55 out of 100",
                          "Low confidence, 20 out of 100",
                          "High confidence, 100 out of 100",
                          "Hidden confidence, 0 out of 100"]))
    func confidenceSentence(score: Double, expected: String) {
        #expect(AccessibilityText.confidence(score: score) == expected)
    }

    @Test func timeLeftIsWrittenInFullWords() {
        #expect(AccessibilityText.timeLeft(until: now + 60, from: now) == "1 minute left")
        #expect(AccessibilityText.timeLeft(until: now + 35 * 60, from: now) == "35 minutes left")
        #expect(AccessibilityText.timeLeft(until: now + 3600, from: now) == "1 hour left")
        #expect(AccessibilityText.timeLeft(until: now + 4 * 3600 + 120, from: now) == "4 hours left")
        #expect(AccessibilityText.timeLeft(until: now - 60, from: now) == "Expired")
    }

    @Test func sourceCardIsOneSentence() {
        let text = AccessibilityText.source(pharmacy: "City Pharmacy", tag: "Seen on-site",
                                            score: 0.82, expiresAt: now + 4 * 3600, now: now)
        #expect(text == "City Pharmacy. Seen on-site. High confidence, 82 out of 100. 4 hours left.")
    }

    @Test func pinSaysKindAndVerified() {
        #expect(AccessibilityText.pin(name: "City Pharmacy", isHospital: false, isVerified: true)
                == "City Pharmacy, verified pharmacy")
        #expect(AccessibilityText.pin(name: "General Hospital", isHospital: true, isVerified: false)
                == "General Hospital, hospital pharmacy")
    }

    @Test func requestUsesSingularAndPlural() {
        #expect(AccessibilityText.request(medicine: "Imatinib", area: "Colombo", status: "Looking", answers: 1)
                == "Imatinib, Colombo. Looking. 1 answer.")
        #expect(AccessibilityText.request(medicine: "Imatinib", area: "Colombo", status: "Looking", answers: 2)
                == "Imatinib, Colombo. Looking. 2 answers.")
    }

    @Test func voteAnnouncement() {
        #expect(AccessibilityText.voteRecorded("Sold out now") == "Sold out now recorded. Plus 10 reputation.")
    }
}