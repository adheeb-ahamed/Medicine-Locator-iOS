//
//  RequestRow.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// One of my requests: medicine, area, status.
struct RequestRow: View {
    let request: MedicineRequest

    var body: some View {
        let status = request.effectiveStatus()
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(request.medicine.displayName)
                    .font(.body.weight(.medium))
                Text(request.areaName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .foregroundStyle(color(for: status))
                .background(color(for: status).opacity(0.12), in: Capsule())
        }
    }

    private func color(for status: MedicineRequest.Status) -> Color {
        switch status {
        case .open:    Theme.accent
        case .found:   Theme.success
        case .expired: Theme.warning
        case .closed:  Theme.tertiary
        }
    }
}
