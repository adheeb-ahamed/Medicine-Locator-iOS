//
//  LockView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

//
//  LockView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Shown when the app is locked. Asks for Face ID automatically.
/// Shows NO personal data — only the brand gradient and the unlock button.
struct LockView: View {
    @Environment(AppViewModel.self) private var app
    @State private var isAuthenticating = false
    @State private var didFail = false

    var body: some View {
        ZStack {
            Theme.heroGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Glass Face ID tile
                Image(systemName: "faceid")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 120, height: 120)
                    .background(.white.opacity(0.16),
                                in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                Text("Medicine Locator is locked")
                    .font(.screenTitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Unlock with Face ID or your passcode to see your requests.")
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                if didFail {
                    Label("Couldn't verify it's you. Try again.", systemImage: "exclamationmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.dangerFill, in: Capsule())
                }

                Spacer()

                Button {
                    Task { await unlock() }
                } label: {
                    Label("Unlock", systemImage: "faceid")
                }
                .buttonStyle(.primaryPill)
                .disabled(isAuthenticating)
            }
            .padding(24)
        }
        .task { await unlock() }   // prompt as soon as the screen appears
    }

    private func unlock() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        didFail = !(await app.unlock())
        isAuthenticating = false
    }
}