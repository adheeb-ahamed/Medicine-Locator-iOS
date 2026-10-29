//
//  RespondView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

//
//  RespondView.swift
//  Short-Supply-medicine-Locater-iOS
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
        .toolbar(viewModel.didSend ? .hidden : .visible, for: .navigationBar)
        .task { await viewModel.load() }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                requestCard

                if viewModel.isOwnRequest {
                    Label("This is your own request.", systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.warning)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.warningTint,
                                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                }

                onSiteCard     // ALWAYS visible, at the top: am I on-site?

                Text("Which licensed pharmacy has it?")
                    .font(.sectionTitle)

                ForEach(viewModel.options) { option in
                    Button {
                        viewModel.selected = option
                    } label: {
                        optionCard(option)
                    }
                    .buttonStyle(.plain)
                }

                if let error = viewModel.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(Theme.danger)
                }
            }
            .padding(20)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) { sendBar }
    }

    /// Teal gradient card: what they're looking for.
    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Someone in \(viewModel.request.areaName) is looking for")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(viewModel.request.medicine.displayName)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(.white)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.heroGradient,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    /// One pharmacy choice — a card with a radio circle.
    private func optionCard(_ option: NearbyPharmacy) -> some View {
        let isSelected = viewModel.selected?.id == option.id
        return HStack(spacing: 10) {
            PharmacyRow(pharmacy: option.pharmacy, distance: option.distance)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Theme.accent : Theme.tertiary)
        }
        .cardStyle(padding: 14)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .stroke(Theme.accent, lineWidth: isSelected ? 2 : 0)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - On-site status card (green / orange / grey)

    private var onSiteCard: some View {
        let style = onSiteStyle
        return HStack(alignment: .top, spacing: 12) {
            IconTile(systemImage: style.icon, color: style.color, tint: style.iconTint)
            VStack(alignment: .leading, spacing: 4) {
                Text(style.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(style.color)
                if let detail = style.detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Button("Check my location again") {
                    Task { await viewModel.refreshLocation() }
                }
                .font(.footnote.weight(.semibold))
                .tint(Theme.accent)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.background,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    /// Same four cases as before — now each picks an icon, colour and text.
    private var onSiteStyle: (icon: String, color: Color, iconTint: Color,
                              background: Color, title: String, detail: String?) {
        if viewModel.currentLocation == nil {
            return ("location.slash", Theme.tertiary, Theme.ringTrack, Theme.card,
                    "Location unavailable", "Your report will be marked not confirmed on-site.")
        }
        guard let selected = viewModel.selected else {
            return ("hand.point.down.fill", Theme.accent, .white, Theme.accentTint,
                    "Choose the pharmacy below", nil)
        }
        if viewModel.isOnSite {
            return ("location.fill", Theme.success, .white, Theme.successTint,
                    "You're at \(selected.pharmacy.name)", "Your report counts as on-site.")
        }
        let away = viewModel.distanceToSelected.map { "You're \(Formatters.distance($0)) away. " } ?? ""
        return ("location.slash", Theme.warning, .white, Theme.warningTint,
                "Not confirmed on-site", away + "Must be within 100 m to count as on-site.")
    }

    // MARK: - Coral send bar

    private var sendBar: some View {
        VStack(spacing: 6) {
            Button {
                Task { await viewModel.send() }
            } label: {
                if viewModel.isSending {
                    ProgressView().tint(.white)
                } else {
                    Label("Report it's available here", systemImage: "checkmark.circle.fill")
                }
            }
            .buttonStyle(.primaryPill)
            .disabled(!viewModel.canSend)

            Text("False reports lower your reputation.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }

    // MARK: - Sent

    private var sentView: some View {
        SuccessView(icon: "hands.sparkles.fill",
                    title: "Thank you",
                    message: "The person looking for \(viewModel.request.medicine.displayName) can now see your report.",
                    onDone: { dismiss() }) {
            VStack(alignment: .leading, spacing: 12) {
                if let selected = viewModel.selected {
                    Label(selected.pharmacy.name, systemImage: "cross.case.fill")
                        .font(.cardTitle)
                }
                Label(viewModel.isOnSite ? "Counted as on-site" : "Marked not confirmed on-site",
                      systemImage: viewModel.isOnSite ? "location.fill" : "location.slash")
                    .foregroundStyle(viewModel.isOnSite ? Theme.success : Theme.warning)
                Label("+25 reputation if they find it there", systemImage: "star.fill")
                    .foregroundStyle(Theme.coralText)
            }
            .font(.subheadline.weight(.semibold))
        }
    }
}