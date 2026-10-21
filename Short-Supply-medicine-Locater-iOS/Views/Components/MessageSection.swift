//
//  MessageSection.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// Shows an error (red) and/or info (green) message inside a Form.
struct MessageSection: View {
    let error: String?
    let info: String?

    var body: some View {
        if let error {
            Section { Text(error).foregroundStyle(Theme.danger) }
        }
        if let info {
            Section { Text(info).foregroundStyle(Theme.success) }
        }
    }
}
