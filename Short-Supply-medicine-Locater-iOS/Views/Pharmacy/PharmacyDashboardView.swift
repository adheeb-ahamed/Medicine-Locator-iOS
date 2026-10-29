//
//  PharmacyDashboardView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  PharmacyDashboardView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Verified pharmacy: post stock, see live posts, mark sold out.
struct PharmacyDashboardView: View {
    @State private var viewModel: PharmacyDashboardViewModel

    init(viewModel: PharmacyDashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let pharmacy = viewModel.pharmacy {
                    pharmacyHeader(pharmacy)
                }
                postCard
                messages
                livePosts
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle("Pharmacy dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    // MARK: - Header

    private func pharmacyHeader(_ pharmacy: Pharmacy) -> some View {
        HStack(spacing: 14) {
            IconTile(systemImage: "cross.case.fill", color: Theme.success, tint: Theme.successTint, size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(pharmacy.name).font(.system(.title3, design: .rounded, weight: .black))
                Label("Verified pharmacy", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.success)
            }
        }
    }

    // MARK: - Post availability

    private var postCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Post availability").font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            TextField("Medicine name", text: $viewModel.medicineName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .modifier(FieldBackground())
            TextField("Strength (optional), e.g. 400 mg", text: $viewModel.strength)
                .modifier(FieldBackground())

            Text("Show for").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(PharmacyPostDuration.allCases) { duration in
                    durationTile(duration)
                }
            }

            if viewModel.isControlled {
                Label("Controlled medicines can't be posted.", systemImage: "exclamationmark.shield.fill")
                    .foregroundStyle(Theme.danger)
            }

            Button {
                Task { await viewModel.post() }
            } label: {
                if viewModel.isPosting {
                    ProgressView().tint(.white)
                } else {
                    Label("Post — in stock now", systemImage: "checkmark.circle.fill")
                }
            }
            .buttonStyle(.primaryPill)
            .disabled(!viewModel.canPost)
        }
        .cardStyle()
    }

    /// Big 6 / 12 / 24 tile — replaces the small segmented picker.
    private func durationTile(_ duration: PharmacyPostDuration) -> some View {
        let isOn = viewModel.duration == duration
        return Button {
            viewModel.duration = duration
        } label: {
            VStack(spacing: 0) {
                Text("\(duration.rawValue)")
                    .font(.bigNumber)
                Text("hours")
                    .font(.caption.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(isOn ? .white : Theme.accent)
            .background(isOn ? Theme.accentFill : Theme.accentTint,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(duration.label)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    @ViewBuilder
    private var messages: some View {
        if let error = viewModel.errorMessage {
            Text(error).foregroundStyle(Theme.danger)
        }
        if let info = viewModel.infoMessage {
            Label(info, systemImage: "checkmark.circle.fill").foregroundStyle(Theme.success)
        }
    }

    // MARK: - Live posts

    private var livePosts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live posts").font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            if viewModel.livePosts.isEmpty {
                Text("No live posts.")
                    .foregroundStyle(.secondary)
                    .cardStyle()
            }

            ForEach(viewModel.livePosts) { post in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(post.medicineName).font(.cardTitle)
                        Text("Ends \(post.expiresAt.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            Label("\(post.stillAvailableCount)", systemImage: "checkmark")
                                .foregroundStyle(Theme.success)
                            Label("\(post.soldOutCount)", systemImage: "xmark")
                                .foregroundStyle(Theme.warning)
                        }
                        .font(.caption.weight(.bold))
                    }
                    Spacer()
                    Button("Sold out") {
                        Task { await viewModel.markSoldOut(post) }
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.warning)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.warningTint, in: Capsule())
                    .buttonStyle(.plain)
                }
                .cardStyle()
                .accessibilityElement(children: .contain)
            }
        }
    }
}

/// Grey rounded background for text fields outside a Form.
private struct FieldBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Theme.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
