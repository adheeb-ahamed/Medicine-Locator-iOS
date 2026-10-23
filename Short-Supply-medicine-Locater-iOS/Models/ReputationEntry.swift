//
//  ReputationEntry.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// One line in a member's reputation ledger. Stored at reputationEvents/{id}
struct ReputationEntry: Codable, Identifiable, Equatable {
    let id: String              // deterministic, e.g. "vote_<responseID>_<userID>" → can only exist once
    let userID: String          // whose reputation changes
    let reason: ReputationEvent
    let responseID: String
    let requestID: String?
    let createdAt: Date

    /// Points come from the reason, so they can't be faked separately.
    var points: Int { reason.points }
}
