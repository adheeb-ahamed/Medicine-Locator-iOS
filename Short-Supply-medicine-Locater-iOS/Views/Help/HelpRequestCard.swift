//
//  HelpRequestCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Someone else's open request in the Help feed.
struct HelpRequestCard: View {
    let item: NearbyRequest

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "pills.fill", color: Theme.coralText, tint: Theme.coralTint)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.request.medicine.displayName)
                    .font(.cardTitle)
                Label(item.request.areaName, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Asked \(item.request.createdAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 0) {
                Text("~\(Formatters.distance(item.distance))")      // ~ because the area is blurred
                    .font(.system(.title3, design: .rounded, weight: .black))
                    .foregroundStyle(Theme.accent)
                Text("away")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}