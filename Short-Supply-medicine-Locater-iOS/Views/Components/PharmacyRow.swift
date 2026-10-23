//
//  PharmacyRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// One pharmacy in a list: icon, name, district, distance.
struct PharmacyRow: View {
    let pharmacy: Pharmacy
    var distance: Double? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: pharmacy.kind == .hospital ? "cross.case.fill" : "pills.fill")
                .foregroundStyle(Theme.accent)
                .frame(width: 36, height: 36)
                .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(pharmacy.name)
                        .font(.body.weight(.medium))
                    if pharmacy.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Theme.success)
                            .accessibilityLabel("Verified")
                    }
                }
                Text(pharmacy.district)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let distance {
                Text(Formatters.distance(distance))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
