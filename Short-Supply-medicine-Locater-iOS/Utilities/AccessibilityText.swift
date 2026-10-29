//
//  AccessibilityText.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  AccessibilityText.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// The sentences VoiceOver reads out loud.
/// Kept here (not inside Views) so every screen says the same thing
/// and we can unit-test them like any other rule.
enum AccessibilityText {

    /// 0.82 → "High confidence, 82 out of 100"
    static func confidence(score: Double) -> String {
        let clamped = min(max(score, 0), 1)            // keep it between 0 and 1
        let percent = Int((clamped * 100).rounded())   // 0.82 → 82
        let level = ConfidenceLevel(score: clamped)    // High / Medium / Low
        return "\(level.label) confidence, \(percent) out of 100"
    }

    /// The screen shows "4h left", but VoiceOver would say "4 h left".
    /// So for speech we write the words out in full.
    static func timeLeft(until date: Date, from now: Date = .now) -> String {
        let minutes = Int(date.timeIntervalSince(now) / 60)
        if minutes <= 0 { return "Expired" }
        if minutes < 60 {
            return minutes == 1 ? "1 minute left" : "\(minutes) minutes left"
        }
        let hours = minutes / 60
        return hours == 1 ? "1 hour left" : "\(hours) hours left"
    }

    /// One sentence for a whole source card.
    /// "City Pharmacy. Seen on-site. High confidence, 82 out of 100. 4 hours left."
    static func source(pharmacy: String, tag: String, score: Double,
                       expiresAt: Date, now: Date = .now) -> String {
        "\(pharmacy). \(tag). \(confidence(score: score)). \(timeLeft(until: expiresAt, from: now))."
    }

    /// Map pin: "City Pharmacy, verified pharmacy" / "General Hospital, hospital pharmacy"
    static func pin(name: String, isHospital: Bool, isVerified: Bool) -> String {
        let kind = isHospital ? "hospital pharmacy" : "pharmacy"
        return "\(name), \(isVerified ? "verified " : "")\(kind)"
    }

    /// Request card: "Imatinib 400 mg, Colombo. Looking. 2 answers."
    static func request(medicine: String, area: String, status: String, answers: Int) -> String {
        "\(medicine), \(area). \(status). \(answers) \(answers == 1 ? "answer" : "answers")."
    }

    /// Spoken after a vote, because the card changes but VoiceOver focus doesn't move.
    static func voteRecorded(_ verdictLabel: String) -> String {
        "\(verdictLabel) recorded. Plus 10 reputation."
    }
}