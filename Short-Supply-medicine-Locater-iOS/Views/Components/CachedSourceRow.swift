//
//  CachedSourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


//
//  CachedSourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// A saved (offline) result — same card look, clearly marked with when it was saved.
struct CachedSourceRow: View {
    let snapshot: SourceSnapshot

    var body: some View {
        HStack(spacing: 14) {
            ConfidenceRing(score: snapshot.score, size: 56, showsLevel: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(snapshot.pharmacyName)
                    .font(.cardTitle)
                    .lineLimit(2)
                if !snapshot.wasOnSite { NotConfirmedLabel() }
                Label("Saved \(snapshot.cachedAt.formatted(.relative(presentation: .named)))",
                      systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .cardStyle()
        .opacity(0.9)                       // slightly faded = "not live"
        .accessibilityElement(children: .combine)
    }
}