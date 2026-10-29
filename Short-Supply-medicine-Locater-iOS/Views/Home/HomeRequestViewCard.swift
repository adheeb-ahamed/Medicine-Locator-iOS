//
//  HomeRequestCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// One of my open requests on Home: medicine, area, and how many answers so far.
struct HomeRequestCard: View {
    let request: MedicineRequest

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "pills.fill")

            VStack(alignment: .leading, spacing: 3) {
                Text(request.medicine.displayName)
                    .font(.cardTitle)
                Label(request.areaName, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 0) {
                Text("\(request.responseCount)")
                    .font(.bigNumber)
                    .foregroundStyle(request.responseCount > 0 ? Theme.accent : Theme.tertiary)
                Text(request.responseCount == 1 ? "answer" : "answers")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}