//
//  SuccessView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Shared "it worked" screen: gradient + confetti, white badge with coral icon,
/// title, message, a summary card, and a coral Done button.
struct SuccessView<Summary: View>: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle = "Done"
    let onDone: () -> Void
    @ViewBuilder var summary: Summary

    var body: some View {
        VStack(spacing: 0) {
            hero

            summary
                .cardStyle()
                .padding(20)

            Spacer()

            Button(buttonTitle, action: onDone)
                .buttonStyle(.primaryPill)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var hero: some View {
        VStack(spacing: 16) {
            // White circular badge with coral icon
            Image(systemName: icon)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Theme.coral)
                .frame(width: 96, height: 96)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                .accessibilityHidden(true)

            Text(title)
                .font(.screenTitle)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                Theme.heroGradient
                ConfettiView()
            }
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: Theme.Radius.hero,
                                              bottomTrailingRadius: Theme.Radius.hero,
                                              style: .continuous))
            .ignoresSafeArea(edges: .top)
        }
    }
}