//
//  SourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  SourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// One report as a card: ring (trust) · pharmacy + tag · time left.
struct SourceRow: View {
    let source: ScoredResponse

    var body: some View {
        let response = source.response

        // Side by side normally; stacked at very large text sizes.
        AdaptiveStack(spacing: 14) {
            ConfidenceRing(score: source.score, size: 56, showsLevel: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(response.pharmacyName)
                    .font(.cardTitle)
                    .lineLimit(2)
                SourceTag(response: response)
                Text("Reported \(response.createdAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.timeLeft(until: response.expiresAt))
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Theme.accent)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)      // decoration — don't read "forward"
            }
        }
        .cardStyle()
        // .ignore = skip the small pieces, read OUR one clear sentence instead
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityText.source(
            pharmacy: response.pharmacyName,
            tag: SourceTag(response: response).text,
            score: source.score,
            expiresAt: response.expiresAt))
        .accessibilityHint("Opens the report details")   // says what a double-tap does
    }
}
