//
//  ClosingRule.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// What should happen to a response after on-site votes come in.
enum ResponseOutcome: Equatable {
    case open          // still showing
    case soldOut       // closed — medicine ran out (no penalty)
    case provedFalse   // closed — it was never there (responder loses reputation)
}

enum ClosingRule {

    static func outcome(soldOutVotes: Int,
                        neverHereVotes: Int,
                        closedByPharmacy: Bool = false) -> ResponseOutcome {
        let soldOut = closedByPharmacy || soldOutVotes >= Constants.Closing.soldOutVotesToClose
        let neverHere = neverHereVotes >= Constants.Closing.neverHereVotesToClose

        // If BOTH happen, "sold out" wins: some people saw it,
        // so we give the responder the benefit of the doubt.
        if soldOut { return .soldOut }
        if neverHere { return .provedFalse }
        return .open
    }

    /// Convenience version that reads the counts from a response.
    static func outcome(for response: AvailabilityResponse,
                        closedByPharmacy: Bool = false) -> ResponseOutcome {
        outcome(soldOutVotes: response.soldOutCount,
                neverHereVotes: response.neverHereCount,
                closedByPharmacy: closedByPharmacy)
    }
}
