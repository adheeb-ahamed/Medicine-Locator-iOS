//
//  ThemePreview.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Not used in the app — a Canvas preview to check the design system.
#Preview("Design system") {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            Text("Find medicine").font(.screenTitle)

            Text("Hero").font(.cardTitle).foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Theme.heroGradient,
                            in: RoundedRectangle(cornerRadius: Theme.Radius.hero))

            VStack(alignment: .leading, spacing: 4) {
                Text("Osu Pharmacy").font(.cardTitle)
                Text("1.2 km").font(.bigNumber).foregroundStyle(Theme.accent)
                Text("Seen on-site 20 min ago").font(.subheadline).foregroundStyle(.secondary)
            }
            .cardStyle()

            Button("Request this medicine") {}.buttonStyle(.primaryPill)
            Button("Directions") {}.buttonStyle(.tealPill)
            Button("Disabled") {}.buttonStyle(.primaryPill).disabled(true)
        }
        .padding()
    }
    .screenBackground()
}

#Preview("Design system — Dark") {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            Text("Find medicine").font(.screenTitle)
            HStack(spacing: 16) {
                ConfidenceRing(score: 0.86, showsLevel: true)
                ConfidenceRing(score: 0.55, showsLevel: true)
                ConfidenceRing(score: 0.22, showsLevel: true)
            }
            StatTile(value: "2.4 km", label: "away", systemImage: "location.fill", style: .card)
            Button("Request this medicine") {}.buttonStyle(.primaryPill)
            Button("Directions") {}.buttonStyle(.tealPill)
        }
        .padding()
    }
    .screenBackground()
    .preferredColorScheme(.dark)
}