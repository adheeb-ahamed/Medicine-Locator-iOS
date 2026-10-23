//
//  NewRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// The "Ask people nearby" form.
struct NewRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NewRequestViewModel

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
            Section("What do you need?") {
                TextField("Medicine name", text: $viewModel.medicineName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                TextField("Strength (optional), e.g. 400 mg", text: $viewModel.strength)
                    .autocorrectionDisabled()
            }

            if viewModel.isControlled {
                Section {
                    Label("Controlled medicines can't be requested here. Please speak to your doctor or a hospital pharmacy.",
                          systemImage: "exclamationmark.shield")
                        .foregroundStyle(Theme.danger)
                }
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
                Label("Your request is anonymous and lasts 7 days.", systemImage: "person.fill.questionmark")
                Label("Not for emergencies — call 1990.", systemImage: "cross.case")
                    .foregroundStyle(Theme.danger)
            }
            .font(.footnote)

            MessageSection(error: viewModel.errorMessage, info: nil)

            Section {
                Button {
                    Task { await viewModel.post() }
                } label: {
                    if viewModel.isPosting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Post request").frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canPost)
            }
        }
        .navigationTitle("New request")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
