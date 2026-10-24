//
//  SourceSnapshot.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// A ranked result as it was when saved — what we show when offline.
struct SourceSnapshot: Identifiable, Equatable {
    let id: String              // the response ID
    let pharmacyID: String
    let pharmacyName: String
    let medicineName: String
    let score: Double
    let wasOnSite: Bool
    let expiresAt: Date
    let cachedAt: Date

    var level: ConfidenceLevel { ConfidenceLevel(score: score) }
}

extension SourceSnapshot {
    /// Freeze a live result into a snapshot.
    init(scored: ScoredResponse, cachedAt: Date = .now) {
        self.init(id: scored.response.id,
                  pharmacyID: scored.response.pharmacyID,
                  pharmacyName: scored.response.pharmacyName,
                  medicineName: scored.response.medicineName,
                  score: scored.score,
                  wasOnSite: scored.response.wasOnSite,
                  expiresAt: scored.response.expiresAt,
                  cachedAt: cachedAt)
    }
}
