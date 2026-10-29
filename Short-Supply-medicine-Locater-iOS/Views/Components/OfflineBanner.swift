//
//  OfflineBanner.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// Orange strip at the top of the app when there's no connection.
struct OfflineBanner: View {
    var body: some View {
        Label("You're offline — showing saved information", systemImage: "wifi.slash")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Theme.warningFill)
            .accessibilityAddTraits(.isHeader)
    }
}
