//
//  TrustScoreCalculator.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Turns a response + its on-site votes into a confidence score from 0.0 to 1.0.
///
/// score = (starting point + confirmations − "never here" reports) × freshness
enum TrustScoreCalculator {

    // MARK: Starting points — who posted it, and were they there?
    static let verifiedPharmacyBase = 0.90
    static let onSiteBase           = 0.55
    static let remoteBase           = 0.30

    // MARK: On-site votes
    static let perConfirmation      = 0.10   // each "Still available"
    static let maxConfirmationBonus = 0.30   // capped, so a crowd can't push it to 1.0
    static let perNeverHere         = 0.20   // each "It was never here"

    // MARK: Freshness
    /// A response loses up to 40% of its score as it gets older.
    static let maxFreshnessLoss     = 0.40

    /// The score for a response at a given moment.
    /// `now` is a parameter so tests can use a fixed time.
    static func score(for response: AvailabilityResponse, at now: Date = .now) -> Double {
        // Expired information is worthless.
        guard response.isLive(at: now) else { return 0 }

        // 1. Starting point
        let base: Double
        switch response.source {
        case .verifiedPharmacy:
            base = verifiedPharmacyBase
        case .community:
            base = response.wasOnSite ? onSiteBase : remoteBase
        }

        // 2. On-site votes (only on-site votes are ever counted — see Phase 6)
        let bonus = min(Double(response.stillAvailableCount) * perConfirmation,
                        maxConfirmationBonus)
        let penalty = Double(response.neverHereCount) * perNeverHere
        // "Sold out now" is deliberately NOT a penalty:
        // the medicine WAS there, it just ran out.

        // 3. Keep it between 0 and 1, then apply freshness
        let raw = min(max(base + bonus - penalty, 0), 1)
        let score = raw * freshness(of: response, at: now)

        // 4. Round to 2 decimals so 0.75 is exactly 0.75 (no floating-point noise)
        return (score * 100).rounded() / 100
    }

    /// Convenience: score → High / Medium / Low / Hidden.
    static func level(for response: AvailabilityResponse, at now: Date = .now) -> ConfidenceLevel {
        ConfidenceLevel(score: score(for: response, at: now))
    }

    /// 1.0 when just posted, sliding down to 0.6 at expiry.
    static func freshness(of response: AvailabilityResponse, at now: Date) -> Double {
        let lifetime = response.expiresAt.timeIntervalSince(response.createdAt)
        guard lifetime > 0 else { return 0 }

        let elapsed = now.timeIntervalSince(response.createdAt)
        let fraction = min(max(elapsed / lifetime, 0), 1)   // 0 = brand new, 1 = about to expire
        return 1 - maxFreshnessLoss * fraction
    }
}
