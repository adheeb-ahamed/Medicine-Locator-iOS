//
//  MedicineSummaryCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Teal gradient card at the top of the results: medicine name + how many places reported it.
struct MedicineSummaryCard: View {
    let name: String
    let resultCount: Int
    var isLoading = false

    private var summary: String {
        if isLoading { return "Checking reports…" }
        switch resultCount {
        case 0:  return "No reports yet"
        case 1:  return "1 place reported it"
        default: return "\(resultCount) places reported it"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "pills.fill", color: .white, tint: .white.opacity(0.18), size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                Text(summary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.heroGradient,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}