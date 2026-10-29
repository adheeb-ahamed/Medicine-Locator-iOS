//
//  StatTile.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Big number + small label. `.glass` sits on the gradient hero, `.card` on the warm background.
struct StatTile: View {
    enum Style { case glass, card }

    let value: String
    let label: String
    var systemImage: String? = nil
    var style: Style = .glass

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
            }
            Text(value)
                .font(.bigNumber)
                .contentTransition(.numericText())   // digits roll to the new number
                .animation(.snappy, value: value)    // the roll needs an animation to play
            Text(label)
                .font(.caption.weight(.semibold))
                .opacity(0.85)
                .lineLimit(2)
        }
        .foregroundStyle(style == .glass ? Color.white : Color.primary)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style == .glass ? Color.white.opacity(0.16) : Theme.card,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: style == .card ? .black.opacity(0.06) : .clear, radius: 10, y: 3)
        .accessibilityElement(children: .combine)   // read as "12, found nearby this week"
    }
}

#Preview {
    HStack {
        StatTile(value: "2.4 km", label: "distance", systemImage: "location.fill", style: .card)
        StatTile(value: "4h", label: "time left", systemImage: "clock.fill", style: .card)
        StatTile(value: "3", label: "on-site checks", systemImage: "checkmark", style: .card)
    }
    .padding()
    .screenBackground()
}
