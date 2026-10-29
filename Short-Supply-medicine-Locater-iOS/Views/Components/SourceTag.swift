//
//  SourceTag.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Who reported it and how: "From the pharmacy" / "Seen on-site" / "Not confirmed on-site".
/// One component so the list card and the detail screen always say the same thing.
struct SourceTag: View {
    let response: AvailabilityResponse

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private enum Kind { case pharmacy, onSite, remote }

    private var kind: Kind {
        if response.source == .verifiedPharmacy { return .pharmacy }
        return response.wasOnSite ? .onSite : .remote
    }

    var text: String {
        switch kind {
        case .pharmacy: "From the pharmacy"
        case .onSite:   "Seen on-site"
        case .remote:   "Not confirmed on-site"
        }
    }

    private var icon: String {
        switch kind {
        case .pharmacy: "checkmark.seal.fill"
        case .onSite:   "location.fill"
        case .remote:   "location.slash"
        }
    }

    private var color: Color {
        switch kind {
        case .pharmacy: Theme.success
        case .onSite:   Theme.accent
        case .remote:   Theme.warning
        }
    }

    private var tint: Color {
        switch kind {
        case .pharmacy: Theme.successTint
        case .onSite:   Theme.accentTint
        case .remote:   Theme.warningTint
        }
    }
}
