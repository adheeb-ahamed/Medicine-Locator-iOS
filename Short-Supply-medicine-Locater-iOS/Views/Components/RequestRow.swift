//
//  RequestRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  RequestRow.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// One of my requests as a card: medicine, area, status chip, answer count.
/// Used on Home AND My Requests.
struct RequestRow: View {
    let request: MedicineRequest

    var body: some View {
        let status = request.effectiveStatus()
        let isOpen = status == .open

        AdaptiveStack(spacing: 14) {
            IconTile(systemImage: "pills.fill",
                     color: isOpen ? Theme.accent : Theme.tertiary,
                     tint: isOpen ? Theme.accentTint : Theme.ringTrack)

            VStack(alignment: .leading, spacing: 5) {
                Text(request.medicine.displayName)
                    .font(.cardTitle)
                Label(request.areaName, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                StatusChip(status: status)
            }

            Spacer(minLength: 8)

            VStack(spacing: 0) {
                Text("\(request.responseCount)")
                    .font(.bigNumber)
                    .foregroundStyle(request.responseCount > 0 ? Theme.accent : Theme.tertiary)
                    .contentTransition(.numericText(value: Double(request.responseCount)))
                    .animation(.snappy, value: request.responseCount)
                Text(request.responseCount == 1 ? "answer" : "answers")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
        .opacity(isOpen ? 1 : 0.85)          // past requests look quieter
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityText.request(
            medicine: request.medicine.displayName,
            area: request.areaName,
            status: status.label,
            answers: request.responseCount))
        .accessibilityHint("Opens this request")
    }
}
