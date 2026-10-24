//
//  RootView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// Shows the right screen for the app's current phase.
struct RootView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        switch app.phase {
        case .loading:
            ProgressView("Loading…")

        case .onboarding:
            WelcomeView()

        case .locked:
            LockView()

        case .ready:
            MainContainerView()

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't connect", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await app.start() }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            }
        }
    }
}
