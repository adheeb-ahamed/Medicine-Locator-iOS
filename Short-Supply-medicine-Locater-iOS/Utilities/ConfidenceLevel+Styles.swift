//
//  ConfidenceLevel+Style.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// How each confidence level LOOKS. Kept out of the model on purpose:
/// ConfidenceLevel (Models) only imports Foundation; colours are a View concern.
extension ConfidenceLevel {
    var color: Color {
        switch self {
        case .high:         Theme.success
        case .medium:       Theme.warning
        case .low, .hidden: Theme.tertiary
        }
    }

    var tint: Color {
        switch self {
        case .high:         Theme.successTint
        case .medium:       Theme.warningTint
        case .low, .hidden: Theme.ringTrack
        }
    }

    /// Short text inside the ring.
    var shortLabel: String {
        switch self {
        case .high:   "HIGH"
        case .medium: "MED"
        case .low:    "LOW"
        case .hidden: "—"
        }
    }
}