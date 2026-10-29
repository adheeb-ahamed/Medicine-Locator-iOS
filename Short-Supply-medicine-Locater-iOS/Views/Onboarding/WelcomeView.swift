//
//  WelcomeView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  WelcomeView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// First-launch screen. "Get started" signs the user in anonymously.
struct WelcomeView: View {
    @Environment(AppViewModel.self) private var app
    @State private var isStarting = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroHeader(eyebrow: "Medicine Locator",
                           title: "Find hard-to-get medicines",
                           subtitle: "People nearby confirm which licensed pharmacies have them in stock.") {
                    exampleCard
                }

                VStack(alignment: .leading, spacing: 18) {
                    FeatureRow(icon: "eye.slash.fill",
                               title: "Ask anonymously",
                               detail: "No name or phone number needed.")
                    FeatureRow(icon: "checkmark.seal.fill",
                               title: "Confirmed on-site",
                               detail: "Answers are checked by people at the pharmacy.")
                    FeatureRow(icon: "lock.fill",
                               title: "Private by default",
                               detail: "Your location is only shared as a rough area.")

                    Text("Not for emergencies. If someone is in danger, call 1990 or go to the nearest hospital.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(24)
            }
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                Button {
                    isStarting = true
                    Task { await app.completeOnboarding() }
                } label: {
                    if isStarting { ProgressView().tint(.white) } else { Text("Get started") }
                }
                .buttonStyle(.primaryPill)
                .disabled(isStarting)
            }
        }
    }

    /// A tilted example of a report card — shows what the app does at a glance.
    /// Decoration only (clearly an example), so VoiceOver skips it.
    private var exampleCard: some View {
        HStack(spacing: 14) {
            ConfidenceRing(score: 0.86, size: 56, showsLevel: true)
            VStack(alignment: .leading, spacing: 6) {
                Text("Example Pharmacy").font(.cardTitle)
                Label("Seen on-site · 20 min ago", systemImage: "location.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
            }
            Spacer(minLength: 0)
        }
        .cardStyle()
        .overlay(alignment: .topTrailing) {
            Label("Anonymous", systemImage: "eye.slash.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.coralText, in: Capsule())
                .rotationEffect(.degrees(4))
                .offset(x: -8, y: -14)
        }
        .rotationEffect(.degrees(-2))
        .padding(.top, 12)
        .accessibilityHidden(true)
    }
}

/// One icon tile + title + description row. `private` = only used in this file.
private struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            IconTile(systemImage: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.cardTitle)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}