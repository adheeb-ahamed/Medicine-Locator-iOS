//
//  CachedSourceRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// A saved (offline) result — clearly marked with when it was saved.
struct CachedSourceRow: View {
    let snapshot: SourceSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(snapshot.pharmacyName).font(.body.weight(.medium))
                Spacer()
                ConfidenceBadge(level: snapshot.level)
            }
            HStack(spacing: 8) {
                if !snapshot.wasOnSite { NotConfirmedLabel() }
                Spacer()
                Label("Saved \(snapshot.cachedAt.formatted(.relative(presentation: .named)))",
                      systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}