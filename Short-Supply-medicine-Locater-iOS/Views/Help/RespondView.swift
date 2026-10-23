//
//  RespondView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// Pick the licensed pharmacy that has the medicine.
struct RespondView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RespondViewModel

    init(viewModel: RespondViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.didSend {
                sentView
            } else {
                form
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var form: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Someone in \(viewModel.request.areaName) is looking for")
                        .foregroundStyle(.secondary)
                    Text(viewModel.request.medicine.displayName)
                        .font(.title3.bold())
                }
            }

            if viewModel.isOwnRequest {
                Section {
                    Text("This is your own request.").foregroundStyle(Theme.warning)
                }
            }

            // ALWAYS visible, at the top: am I on-site?
            Section("Your location") {
                onSiteStatus
                Button("Check my location again") {
                    Task { await viewModel.refreshLocation() }
                }
                .font(.footnote)
            }

            Section("Which licensed pharmacy has it?") {
                ForEach(viewModel.options) { option in
                    Button {
                        viewModel.selected = option
                    } label: {
                        HStack {
                            PharmacyRow(pharmacy: option.pharmacy, distance: option.distance)
                            if viewModel.selected?.id == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }

            MessageSection(error: viewModel.errorMessage, info: nil)

            Section {
                Button {
                    Task { await viewModel.send() }
                } label: {
                    if viewModel.isSending {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Report it's available here").frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canSend)
            } footer: {
                Text("False reports lower your reputation.")
            }
        }
    }

    /// Green / orange / grey status line.
    @ViewBuilder
    private var onSiteStatus: some View {
        if viewModel.currentLocation == nil {
            Label("Location unavailable — your report will be marked not confirmed on-site.",
                  systemImage: "location.slash")
                .foregroundStyle(.secondary)
        } else if viewModel.selected == nil {
            Label("Choose the pharmacy below.", systemImage: "hand.point.down")
                .foregroundStyle(.secondary)
        } else if viewModel.isOnSite {
            Label("You're at \(viewModel.selected!.pharmacy.name) — your report counts as on-site.",
                  systemImage: "location.fill")
                .foregroundStyle(Theme.success)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                NotConfirmedLabel()
                if let distance = viewModel.distanceToSelected {
                    Text("You're \(Formatters.distance(distance)) from this pharmacy. Must be within 100 m to count as on-site.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    /// Shown after a report is sent.
    private var sentView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.success)
            Text("Thank you")
                .font(.title.bold())
            Text("The person looking for \(viewModel.request.medicine.displayName) can now see your report. If they find it there, you earn +25 reputation.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .controlSize(.large)
        }
        .padding(24)
    }
}
