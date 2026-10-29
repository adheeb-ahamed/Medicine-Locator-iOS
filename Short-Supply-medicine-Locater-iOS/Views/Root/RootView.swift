//
//  RootView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  RootView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Shows the right screen for the app's current phase.
struct RootView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        switch app.phase {
        case .loading:
            ZStack {
                Theme.heroGradient.ignoresSafeArea()
                VStack(spacing: 14) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 44, weight: .semibold))
                    ProgressView().tint(.white)
                }
                .foregroundStyle(.white)
            }
            .accessibilityLabel("Loading")

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
                .buttonStyle(.primaryPill)
                .padding(.horizontal, 40)
            }
            .screenBackground()
        }
    }
}