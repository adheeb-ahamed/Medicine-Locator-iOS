//
//  RequestPostedView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// Confirmation after posting.
struct RequestPostedView: View {
    let request: MedicineRequest
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.success)

            Text("Request posted")
                .font(.title.bold())

            Text("People in \(request.areaName) can now tell you which licensed pharmacy has \(request.medicine.displayName).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Label("Answers appear in My Requests", systemImage: "tray.full")
                Label("Reports from people at the pharmacy are marked", systemImage: "location.fill")
                Label("Expires \(request.expiresAt.formatted(date: .abbreviated, time: .omitted)) — you can renew it",
                      systemImage: "clock")
            }
            .font(.subheadline)

            Spacer()

            Button(action: onDone) {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .controlSize(.large)
        }
        .padding(24)
        .navigationBarBackButtonHidden()
    }
}
