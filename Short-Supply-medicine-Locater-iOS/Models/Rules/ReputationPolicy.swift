//
//  ReputationPolicy.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
// This determines how much trust each community member has 

import Foundation

/// Things that change a member's reputation.
enum ReputationEvent: CaseIterable {
    case confirmedOnSite       // you confirmed stock while inside the pharmacy
    case responseMarkedFound   // the requester found the medicine through your response
    case responseProvedFalse   // on-site members reported "It was never here"

    var points: Int {
        switch self {
        case .confirmedOnSite:      10
        case .responseMarkedFound:  25
        case .responseProvedFalse: -15
        }
    }
}

enum ReputationPolicy {
    /// New reputation after an event. Never drops below 0.
    static func apply(_ event: ReputationEvent, to reputation: Int) -> Int {
        max(0, reputation + event.points)
    }
}
