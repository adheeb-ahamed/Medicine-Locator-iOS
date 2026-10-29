//
//  NewRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  NewRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// The "Ask people nearby" form — privacy card first, coral Post button at the bottom.
struct NewRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewRequestViewModel
    @Environment(ServiceContainer.self) private var services
    @State private var showingScanner = false

    init(viewModel: NewRequestViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if let posted = viewModel.postedRequest {
                RequestPostedView(request: posted) { dismiss() }
            } else {
                form
            }
        }
        .task { await viewModel.load() }
    }

    private var form: some View {
        Form {
            privacyCard
                .cardRow()

            Section("What do you need?") {
                TextField("Medicine name", text: $viewModel.medicineName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                TextField("Strength (optional), e.g. 400 mg", text: $viewModel.strength)
                    .autocorrectionDisabled()
                Button {
                    showingScanner = true
                } label: {
                    Label("Scan the box instead", systemImage: "text.viewfinder")
                        .foregroundStyle(Theme.coralText)
                }
            }

            if viewModel.isControlled {
                Section {
                    Label("Controlled medicines can't be requested here. Please speak to your doctor or a hospital pharmacy.",
                          systemImage: "exclamationmark.shield.fill")
                        .foregroundStyle(Theme.danger)
                }
                .listRowBackground(Theme.dangerTint)
            }

            Section {
                Picker("Area", selection: $viewModel.selectedDistrict) {
                    Text("Choose…").tag(String?.none)
                    ForEach(viewModel.districts, id: \.self) { district in
                        Text(district).tag(Optional(district))
                    }
                }
            } header: {
                Text("Where?")
            } footer: {
                Text("Only your district is shared — never your exact location.")
            }

            Section {
                Label("Not for emergencies — call 1990.", systemImage: "cross.case.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.danger)
            }

            MessageSection(error: viewModel.errorMessage, info: nil)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) { postBar }
        .navigationTitle("New request")
        .sheet(isPresented: $showingScanner) {
            NavigationStack {
                ScanView(viewModel: services.makeScanViewModel()) { name, strength in
                    viewModel.medicineName = name
                    if let strength { viewModel.strength = strength }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    /// Gradient card: privacy promise shown BEFORE the user types anything.
    private var privacyCard: some View {
        HStack(alignment: .top, spacing: 14) {
            IconTile(systemImage: "eye.slash.fill", color: .white, tint: .white.opacity(0.18))
            VStack(alignment: .leading, spacing: 4) {
                Text("Anonymous request")
                    .font(.cardTitle)
                    .foregroundStyle(.white)
                Text("No name is shown. Only your district is shared. Lasts 7 days and you can renew it.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.heroGradient,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var postBar: some View {
        Button {
            Task { await viewModel.post() }
        } label: {
            if viewModel.isPosting {
                ProgressView().tint(.white)
            } else {
                Label("Post request", systemImage: "megaphone.fill")
            }
        }
        .buttonStyle(.primaryPill)
        .disabled(!viewModel.canPost)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}