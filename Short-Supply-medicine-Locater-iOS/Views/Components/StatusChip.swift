//
//  StatusChip.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// "Looking" / "Found" / "Expired" / "Closed" — used on request cards and request detail.
struct StatusChip: View {
    let status: MedicineRequest.Status

    var body: some View {
        Text(status.label)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var color: Color {
        switch status {
        case .open:    Theme.accent
        case .found:   Theme.success
        case .expired: Theme.warning
        case .closed:  Color.secondary
        }
    }

    private var tint: Color {
        switch status {
        case .open:    Theme.accentTint
        case .found:   Theme.successTint
        case .expired: Theme.warningTint
        case .closed:  Theme.ringTrack
        }
    }
}