//
//  WelcomeView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// First-launch screen. "Get started" signs the user in anonymously.
struct WelcomeView: View {
    @Environment(AppViewModel.self) private var app
    @State private var isStarting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer()

            Image(systemName: "cross.case")
                .font(.system(size: 56))
                .foregroundStyle(Theme.accent)

            VStack(alignment: .leading, spacing: 8) {
                Text("Find hard-to-get medicines")
                    .font(.largeTitle.bold())
                Text("People nearby confirm which licensed pharmacies have them in stock.")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "person.fill.questionmark",
                           title: "Ask anonymously",
                           detail: "No name or phone number needed.")
                FeatureRow(icon: "checkmark.seal",
                           title: "Confirmed on-site",
                           detail: "Answers are checked by people at the pharmacy.")
                FeatureRow(icon: "lock",
                           title: "Private by default",
                           detail: "Your location is only shared as a rough area.")
            }

            Spacer()

            Text("Not for emergencies. If someone is in danger, call 1990 or go to the nearest hospital.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                isStarting = true
                Task { await app.completeOnboarding() }
            } label: {
                Group {
                    if isStarting { ProgressView() } else { Text("Get started") }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .controlSize(.large)
            .disabled(isStarting)
        }
        .padding(24)
    }
}

/// One icon + title + description row. `private` = only used in this file.
private struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
