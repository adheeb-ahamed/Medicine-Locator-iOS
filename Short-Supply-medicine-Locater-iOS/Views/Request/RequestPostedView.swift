//
//  RequestPostedView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  RequestPostedView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Confirmation after posting — uses the shared SuccessView.
struct RequestPostedView: View {
    let request: MedicineRequest
    let onDone: () -> Void

    var body: some View {
        SuccessView(icon: "megaphone.fill",
                    title: "Request posted",
                    message: "People in \(request.areaName) can now tell you which licensed pharmacy has \(request.medicine.displayName).",
                    onDone: onDone) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Answers appear in My Requests", systemImage: "tray.full.fill")
                Label("Reports from people at the pharmacy are marked", systemImage: "location.fill")
                Label("Expires \(request.expiresAt.formatted(date: .abbreviated, time: .omitted)) — you can renew it",
                      systemImage: "clock.fill")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.accent)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}