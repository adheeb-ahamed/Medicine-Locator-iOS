//
//  MapPharmacyCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// One card in the bottom carousel: icon, name, district, distance.
struct MapPharmacyCard: View {
    let pharmacy: Pharmacy
    let distance: Double?
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            IconTile(systemImage: pharmacy.kind == .hospital ? "cross.case.fill" : "pills.fill",
                     color: pharmacy.isVerified ? Theme.success : Theme.accent,
                     tint: pharmacy.isVerified ? Theme.successTint : Theme.accentTint)

            VStack(alignment: .leading, spacing: 3) {
                Text(pharmacy.name)
                    .font(.cardTitle)
                    .lineLimit(1)
                Text(pharmacy.district)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if pharmacy.isVerified {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.success)
                }
            }

            Spacer(minLength: 4)

            if let distance {
                VStack(spacing: 0) {
                    Text(Formatters.distance(distance))
                        .font(.system(.title3, design: .rounded, weight: .black))
                        .foregroundStyle(Theme.accent)
                    Text("away")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle(padding: 14)
        .frame(width: 300)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .stroke(Theme.accent, lineWidth: isSelected ? 2 : 0)   // outline = this pin is selected
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}