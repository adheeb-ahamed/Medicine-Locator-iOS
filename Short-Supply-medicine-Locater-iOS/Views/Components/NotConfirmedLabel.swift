//
//  NotConfirmedLabel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// Shown on responses from people who weren't at the pharmacy.
struct NotConfirmedLabel: View {
    var body: some View {
        Label("Not confirmed on-site", systemImage: "location.slash")
            .font(.caption)
            .foregroundStyle(Theme.warning)
    }
}
