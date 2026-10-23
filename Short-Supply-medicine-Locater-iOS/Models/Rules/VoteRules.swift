//
//  VoteRules.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Everything that changes when someone votes on-site.
struct VoteOutcome {
    let updatedResponse: AvailabilityResponse     // counts + expiry after the vote
    let confirmation: Confirmation                // the vote itself
    let reputationEntries: [ReputationEntry]      // +10 for the voter, maybe −15 for the responder
}

enum VoteRules {

    static func apply(_ verdict: Confirmation.Verdict,
                      by voterID: String,
                      to response: AvailabilityResponse,
                      at now: Date = .now) -> VoteOutcome {
        var updated = response

        // 1. Count the vote
        switch verdict {
        case .stillAvailable:
            updated.stillAvailableCount += 1
            // Community posts live longer when confirmed: 6 h + 2 h each, max 12 h (Phase 3)
            if response.source == .community {
                updated.expiresAt = ExpiryPolicy.communityResponseExpiry(
                    createdAt: response.createdAt,
                    onSiteConfirmations: updated.stillAvailableCount)
            }
        case .soldOut:
            updated.soldOutCount += 1
        case .neverHere:
            updated.neverHereCount += 1
        }

        // 2. The voter earns +10 for checking on-site
        var entries = [
            ReputationEntry(id: "vote_\(response.id)_\(voterID)",
                            userID: voterID,
                            reason: .confirmedOnSite,
                            responseID: response.id,
                            requestID: response.requestID,
                            createdAt: now)
        ]

        // 3. If THIS vote just proved the report false, the responder loses 15
        if ClosingRule.outcome(for: response) == .open,
           ClosingRule.outcome(for: updated) == .provedFalse {
            entries.append(
                ReputationEntry(id: "false_\(response.id)",
                                userID: response.responderID,
                                reason: .responseProvedFalse,
                                responseID: response.id,
                                requestID: response.requestID,
                                createdAt: now))
        }

        let confirmation = Confirmation(id: voterID,
                                        responseID: response.id,
                                        verdict: verdict,
                                        wasInsideGeofence: true,
                                        createdAt: now)

        return VoteOutcome(updatedResponse: updated,
                           confirmation: confirmation,
                           reputationEntries: entries)
    }
}
