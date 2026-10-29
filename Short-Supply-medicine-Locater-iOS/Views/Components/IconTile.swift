//
//  IconTile.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// SF Symbol on a tinted rounded square (teal by default, coral for hopeful actions).
struct IconTile: View {
    let systemImage: String
    var color: Color = Theme.accent
    var tint: Color = Theme.accentTint
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(tint, in: RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous))
            .accessibilityHidden(true)   // the text next to it already says what it is
    }
}

#Preview {
    HStack(spacing: 12) {
        IconTile(systemImage: "pills.fill")
        IconTile(systemImage: "hand.raised.fill", color: Theme.coral, tint: Theme.coralTint)
        IconTile(systemImage: "checkmark.seal.fill", color: Theme.success, tint: Theme.successTint)
    }
    .padding()
}