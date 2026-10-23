//
//  OnSiteConfirmView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// "Are you at this pharmacy?" — the 3 on-site buttons.
struct OnSiteConfirmView: View {
    @State private var viewModel: OnSiteConfirmViewModel

    init(viewModel: OnSiteConfirmViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Section {
            switch viewModel.state {
            case .checking, .sending:
                HStack { ProgressView(); Text("Checking your location…").foregroundStyle(.secondary) }

            case .ownResponse:
                Text("This is your report. Others at the pharmacy can confirm it.")
                    .foregroundStyle(.secondary)

            case .alreadyVoted:
                Label("You've already checked this report.", systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)

            case .locationOff:
                Text("Turn on location to confirm stock on-site.")
                    .foregroundStyle(.secondary)

            case .tooFar(let distance):
                VStack(alignment: .leading, spacing: 6) {
                    Text("You're \(Formatters.distance(distance)) away.")
                    Text("Go to the pharmacy to confirm. Only on-site checks count.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Check again") { Task { await viewModel.check() } }
                }

            case .ready:
                ForEach(Confirmation.Verdict.allCases, id: \.self) { verdict in
                    Button {
                        Task { await viewModel.vote(verdict) }
                    } label: {
                        Label(verdict.label, systemImage: symbol(for: verdict))
                    }
                    .foregroundStyle(color(for: verdict))
                }

            case .done(let verdict):
                Label("Thanks — \"\(verdict.label)\" recorded. +10 reputation.",
                      systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Theme.success)

            case .failed(let message):
                VStack(alignment: .leading, spacing: 6) {
                    Text(message).foregroundStyle(Theme.danger)
                    Button("Try again") { Task { await viewModel.check() } }
                }
            }
        } header: {
            Text("Are you at this pharmacy?")
        } footer: {
            Text("Votes only count within 100 m of the pharmacy.")
        }
        .task { await viewModel.check() }
    }

    private func symbol(for verdict: Confirmation.Verdict) -> String {
        switch verdict {
        case .stillAvailable: "checkmark.circle.fill"
        case .soldOut:        "xmark.circle"
        case .neverHere:      "exclamationmark.triangle"
        }
    }

    private func color(for verdict: Confirmation.Verdict) -> Color {
        switch verdict {
        case .stillAvailable: Theme.success
        case .soldOut:        Theme.warning
        case .neverHere:      Theme.danger
        }
    }
}
