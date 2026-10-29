//
//  VerifyPharmacyView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// "I run a pharmacy" — shows the form, or the status of an existing application.
struct VerifyPharmacyView: View {
    @State private var viewModel: VerifyPharmacyViewModel

    init(viewModel: VerifyPharmacyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            if !viewModel.canApply {
                Section {
                    Label("Pharmacy accounts need an email. Go to Account → Save my reputation first.",
                          systemImage: "envelope.badge")
                        .foregroundStyle(Theme.warning)
                }
            }

            if let existing = viewModel.existing {
                Section("Your application") {
                    LabeledContent("Pharmacy", value: existing.pharmacyName)
                    LabeledContent("Status", value: existing.status.label)
                    if let note = existing.note, existing.status == .rejected {
                        Text("Reason: \(note)").foregroundStyle(Theme.danger)
                    }
                }
                if existing.status == .approved {
                    Section {
                        Text("Pull down on the Account screen to refresh — your pharmacy dashboard will appear.")
                            .font(.footnote)
                    }
                }
            }

            if viewModel.existing == nil || viewModel.existing?.status == .rejected {
                Section {
                    Picker("Pharmacy", selection: $viewModel.selectedPharmacyID) {
                        Text("Choose…").tag(String?.none)
                        ForEach(viewModel.pharmacies) { pharmacy in
                            Text("\(pharmacy.name) — \(pharmacy.district)").tag(Optional(pharmacy.id))
                        }
                    }
                    .pickerStyle(.navigationLink)
                    TextField("NMRA licence / registration number", text: $viewModel.licenceNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                } header: {
                    Text("Your pharmacy")
                } footer: {
                    Text("Must be on the NMRA licensed-pharmacy list.")
                }

                Section {
                    TextField("Contact name (pharmacist in charge)", text: $viewModel.contactName)
                        .textContentType(.name)
                    TextField("Phone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Contact")
                } footer: {
                    Text("A moderator will call the pharmacy's public number to confirm you work there.")
                }

                MessageSection(error: viewModel.errorMessage, info: nil)

                Section {
                    Button {
                        Task { await viewModel.submit() }
                    } label: {
                        if viewModel.isSubmitting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Submit for review").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
        }
        .screenBackground()
        .navigationTitle("Verify your pharmacy")
        .task { await viewModel.load() }
    }
}
