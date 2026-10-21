//
//  LockView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// Shown when the app is locked. Asks for Face ID automatically.
struct LockView: View {
    @Environment(AppViewModel.self) private var app
    @State private var isAuthenticating = false
    @State private var didFail = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)

            Text("Medicine Locator is locked")
                .font(.title2.bold())

            Text("Unlock with Face ID or your passcode to see your requests.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if didFail {
                Text("Couldn't verify it's you. Try again.")
                    .font(.footnote)
                    .foregroundStyle(Theme.danger)
            }

            Spacer()

            Button {
                Task { await unlock() }
            } label: {
                Label("Unlock", systemImage: "faceid")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .controlSize(.large)
            .disabled(isAuthenticating)
        }
        .padding(24)
        .task { await unlock() }   // prompt as soon as the screen appears
    }

    private func unlock() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        didFail = !(await app.unlock())
        isAuthenticating = false
    }
}
