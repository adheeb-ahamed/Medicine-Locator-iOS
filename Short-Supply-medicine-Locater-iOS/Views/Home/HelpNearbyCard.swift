//
//  HelpNearbyCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// The coral "I can help" card — the hopeful action on Home.
struct HelpNearbyCard: View {
    let count: Int

    private var title: String {
        switch count {
        case 0:  "Help people nearby"
        case 1:  "1 person near you needs medicine"
        default: "\(count) people near you need medicine"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "hand.raised.fill", color: .white, tint: Theme.coral, size: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.cardTitle)
                    .foregroundStyle(.primary)
                Text("Tell them which pharmacy has it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("I can help")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.coralFill, in: Capsule())   // darker coral: small white text passes AA
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.coralTint,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens requests from people near you")
    }
}