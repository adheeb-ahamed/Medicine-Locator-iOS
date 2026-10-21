//
//  ConfidenceLevel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import Foundation

/// How much we trust a "this pharmacy has it" response.
enum ConfidenceLevel: String, Codable, CaseIterable {
    case high, medium, low, hidden

    /// Proposal thresholds: High ≥ 0.70, Medium 0.40–0.69, Low 0.15–0.39, else hidden.
    init(score: Double) {
        switch score {
        case 0.70...:       self = .high
        case 0.40..<0.70:   self = .medium
        case 0.15..<0.40:   self = .low
        default:            self = .hidden
        }
    }

    var label: String {
        switch self {
        case .high:   "High"
        case .medium: "Medium"
        case .low:    "Low"
        case .hidden: "Hidden"
        }
    }

    /// Scores below 0.15 are never shown to users.
    var isVisible: Bool { self != .hidden }
}
