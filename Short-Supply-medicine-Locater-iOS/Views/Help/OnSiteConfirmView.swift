//
//  OnSiteConfirmView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

//
//  OnSiteConfirmView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// "Are you at this pharmacy?" — answer cards that say what each choice DOES.
struct OnSiteConfirmView: View {
    @State private var viewModel: OnSiteConfirmViewModel

    init(viewModel: OnSiteConfirmViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                IconTile(systemImage: "location.fill", size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Are you at this pharmacy?").font(.cardTitle)
                    Text("Votes only count within 100 m.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .cardStyle()
        .task { await viewModel.check() }
        // After a vote the card changes, but VoiceOver focus stays put,
        // so a blind user wouldn't know it worked. Announce it out loud.
        .onChange(of: viewModel.state) { _, newState in
            if case .done(let verdict) = newState {
                AccessibilityNotification.Announcement(
                    AccessibilityText.voteRecorded(verdict.label)
                ).post()
            }
        }
        // Feel the result: success when the vote is saved, error if it failed.
        // Returning nil = no vibration for the other state changes.
        .sensoryFeedback(trigger: viewModel.state) { _, newState in
            switch newState {
            case .done:   .success
            case .failed: .error
            default:      nil
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .checking, .sending:
            HStack(spacing: 10) {
                ProgressView()
                Text(viewModel.state == .sending ? "Sending…" : "Checking your location…")
                    .foregroundStyle(.secondary)
            }

        case .ownResponse:
            info("This is your report. Others at the pharmacy can confirm it.", icon: "person.fill")

        case .alreadyVoted:
            info("You've already checked this report.", icon: "checkmark.circle")

        case .locationOff:
            info("Turn on location to confirm stock on-site.", icon: "location.slash")

        case .tooFar(let distance):
            info("You're \(Formatters.distance(distance)) away. Go to the pharmacy to confirm — only on-site checks count.",
                 icon: "figure.walk")
            Button("Check again") { Task { await viewModel.check() } }
                .buttonStyle(.tealPill)

        case .ready:
            ForEach(Confirmation.Verdict.allCases, id: \.self) { verdict in
                Button {
                    Task { await viewModel.vote(verdict) }
                } label: {
                    answerCard(verdict)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(verdict.label)                 // "Sold out now"
                .accessibilityHint(consequence(for: verdict))      // "Two sold-out votes close it…"
            }

        case .done(let verdict):
            HStack(spacing: 12) {
                IconTile(systemImage: "checkmark.seal.fill", color: Theme.success, tint: Theme.card)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\u{201C}\(verdict.label)\u{201D} recorded")
                        .font(.subheadline.weight(.bold))
                    Text("+10 reputation")
                        .font(.system(.title3, design: .rounded, weight: .black))
                        .foregroundStyle(Theme.success)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.successTint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

        case .failed(let message):
            Text(message).foregroundStyle(Theme.danger)
            Button("Try again") { Task { await viewModel.check() } }
                .buttonStyle(.tealPill)
        }
    }

    // MARK: - Pieces

    private func info(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    /// One answer: icon, label, and the consequence in plain words.
    private func answerCard(_ verdict: Confirmation.Verdict) -> some View {
        HStack(spacing: 12) {
            IconTile(systemImage: symbol(for: verdict), color: color(for: verdict), tint: tint(for: verdict))
            VStack(alignment: .leading, spacing: 2) {
                Text(verdict.label)
                    .font(.cardTitle)
                    .foregroundStyle(color(for: verdict))
                Text(consequence(for: verdict))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(12)
        .background(Theme.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint(for: verdict), lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
    }

    /// What happens if you pick this — matches the rules in ExpiryPolicy / ClosingRule / ReputationPolicy.
    private func consequence(for verdict: Confirmation.Verdict) -> String {
        switch verdict {
        case .stillAvailable:
            viewModel.response.source == .community
                ? "Keeps it visible 2 hours longer (up to 12 h)."
                : "Confirms the pharmacy's post."
        case .soldOut:
            "Two sold-out votes close it. Nobody is penalised."
        case .neverHere:
            "Flags the report as false. The reporter loses reputation."
        }
    }

    private func symbol(for verdict: Confirmation.Verdict) -> String {
        switch verdict {
        case .stillAvailable: "checkmark.circle.fill"
        case .soldOut:        "xmark.circle.fill"
        case .neverHere:      "exclamationmark.triangle.fill"
        }
    }

    private func color(for verdict: Confirmation.Verdict) -> Color {
        switch verdict {
        case .stillAvailable: Theme.success
        case .soldOut:        Theme.warning
        case .neverHere:      Theme.danger
        }
    }

    private func tint(for verdict: Confirmation.Verdict) -> Color {
        switch verdict {
        case .stillAvailable: Theme.successTint
        case .soldOut:        Theme.warningTint
        case .neverHere:      Theme.dangerTint
        }
    }
}
