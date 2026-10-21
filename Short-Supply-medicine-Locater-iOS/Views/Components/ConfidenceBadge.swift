//
//  ConfidenceBadge.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// The High / Medium / Low pill shown next to each pharmacy.
struct ConfidenceBadge: View {
    let level: ConfidenceLevel

    var body: some View {
        Label(level.label, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
            .accessibilityLabel("\(level.label) confidence")
    }

    private var color: Color {
        switch level {
        case .high:   Theme.success
        case .medium: Theme.warning
        case .low, .hidden: Theme.tertiary
        }
    }

    private var symbol: String {
        switch level {
        case .high:   "checkmark.seal.fill"
        case .medium: "exclamationmark.circle"
        case .low:    "questionmark.circle"
        case .hidden: "eye.slash"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(ConfidenceLevel.allCases, id: \.self) { level in
            ConfidenceBadge(level: level)
        }
    }
}
