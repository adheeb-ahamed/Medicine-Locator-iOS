//
//  PermissionPromptView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

//
//  PermissionPromptView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Explains WHY before iOS shows its permission popup.
struct PermissionPromptView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                IconTile(systemImage: icon)
                Text(title).font(.cardTitle)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(buttonTitle, action: action)
                .buttonStyle(.tealPill)
        }
        .padding(.vertical, 6)
    }
}