//
//  PharmacyDashboardView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// Verified pharmacy: post stock, see live posts, mark sold out.
struct PharmacyDashboardView: View {
    @State private var viewModel: PharmacyDashboardViewModel

    init(viewModel: PharmacyDashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if let pharmacy = viewModel.pharmacy {
                Section {
                    PharmacyRow(pharmacy: pharmacy)
                    Label("Verified pharmacy", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(Theme.success)
                }
            }

            Section("Post availability") {
                TextField("Medicine name", text: $viewModel.medicineName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                TextField("Strength (optional), e.g. 400 mg", text: $viewModel.strength)
                Picker("Show for", selection: $viewModel.duration) {
                    ForEach(PharmacyPostDuration.allCases) { duration in
                        Text(duration.label).tag(duration)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.isControlled {
                    Label("Controlled medicines can't be posted.", systemImage: "exclamationmark.shield")
                        .foregroundStyle(Theme.danger)
                }

                Button {
                    Task { await viewModel.post() }
                } label: {
                    if viewModel.isPosting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Post — in stock now").frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canPost)
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)

            Section {
                if viewModel.livePosts.isEmpty {
                    Text("No live posts.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.livePosts) { post in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.medicineName).font(.body.weight(.medium))
                        HStack {
                            Text("Ends \(post.expiresAt.formatted(date: .omitted, time: .shortened))")
                            Spacer()
                            Text("✓ \(post.stillAvailableCount)  ✗ \(post.soldOutCount)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button("Sold out") {
                            Task { await viewModel.markSoldOut(post) }
                        }
                        .tint(Theme.warning)
                    }
                }
            } header: {
                Text("Live posts")
            } footer: {
                Text("Swipe left on a post to mark it sold out.")
            }
        }
        .navigationTitle("Pharmacy dashboard")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
