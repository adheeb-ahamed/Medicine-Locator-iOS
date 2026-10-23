//
//  Confirmation.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-18.
//
// This shows the communiy confirmation.

import Foundation

/// One person's vote on a response. Stored at .../responses/{responseID}/confirmations/{userID}
struct Confirmation: Codable, Identifiable {
    enum Verdict: String, Codable, CaseIterable {
        case stillAvailable
        case soldOut
        case neverHere

        var label: String {
            switch self {
            case .stillAvailable: "Still available"
            case .soldOut:        "Sold out now"
            case .neverHere:      "It was never here"
            }
        }
        
        /// The counter on AvailabilityResponse this verdict increases.
        var countField: String {
            switch self {
            case .stillAvailable: "stillAvailableCount"
            case .soldOut:        "soldOutCount"
            case .neverHere:      "neverHereCount"
            }
        }
    }

    let id: String              // = userID, so each person gets exactly ONE vote
    let responseID: String
    var verdict: Verdict
    var wasInsideGeofence: Bool // only true votes count toward the score
    var createdAt: Date
}
