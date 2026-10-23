//
//  SourceRanking.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// A response together with its current trust score.
struct ScoredResponse: Identifiable {
    let response: AvailabilityResponse
    let score: Double

    var level: ConfidenceLevel { ConfidenceLevel(score: score) }
    var id: String { response.id }
}

/// Turns raw responses into the list users see.
enum SourceRanking {
    static func rank(_ responses: [AvailabilityResponse], at now: Date = .now) -> [ScoredResponse] {
        responses
            .filter { ClosingRule.outcome(for: $0) == .open }          // drop sold-out / proved-false
            .map { ScoredResponse(response: $0,
                                  score: TrustScoreCalculator.score(for: $0, at: now)) }
            .filter { $0.level.isVisible }                             // drop scores below 0.15 (incl. expired)
            .sorted { $0.score > $1.score }                            // most trustworthy first
    }
}
