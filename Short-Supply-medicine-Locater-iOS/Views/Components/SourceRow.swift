//
//  SourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// One report: pharmacy, confidence badge, how it was reported, how long ago.
struct SourceRow: View {
    let source: ScoredResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(source.response.pharmacyName)
                    .font(.body.weight(.medium))
                Spacer()
                ConfidenceBadge(level: source.level)
            }
            HStack(spacing: 8) {
                if source.response.source == .verifiedPharmacy {
                    Label("From the pharmacy", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.success)
                } else if source.response.wasOnSite {
                    Label("Seen on-site", systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    NotConfirmedLabel()
                }
                Spacer()
                Text(source.response.createdAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
