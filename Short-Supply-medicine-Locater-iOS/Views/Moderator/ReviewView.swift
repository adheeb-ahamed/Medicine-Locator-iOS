//
//  ReviewView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// Review one application. Approve is disabled until the checklist is complete.
struct ReviewView: View {
    let application: VerificationRequest
    let viewModel: ModeratorViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var calledPublicNumber = false
    @State private var rejectNote = ""
    @State private var isWorking = false

    var body: some View {
        let listed = viewModel.pharmacy(for: application)
        let licenceOK = VerificationChecklist.licenceMatches(application)

        List {
            Section("Application") {
                LabeledContent("Pharmacy", value: application.pharmacyName)
                LabeledContent("Licence entered", value: application.licenceNumber)
                LabeledContent("Contact", value: application.contactName)
                LabeledContent("Applicant phone", value: application.phone)
            }

            Section("Licensed list (NMRA)") {
                if let listed {
                    LabeledContent("Licence no.", value: listed.id)
                    LabeledContent("Address", value: listed.address)
                    if let phone = listed.phone, let url = URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })") {
                        Link(destination: url) {
                            Label("Call public number \(phone)", systemImage: "phone")
                        }
                    } else {
                        Text("No public number in the list — find it on the pharmacy's sign or Google Maps. Don't use the applicant's number.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("This pharmacy isn't in the licensed list.").foregroundStyle(Theme.danger)
                }
            }

            Section("Checklist") {
                Label(licenceOK ? "Licence number matches the list" : "Licence number does NOT match",
                      systemImage: licenceOK ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(licenceOK ? Theme.success : Theme.danger)
                Toggle("I called the pharmacy's public number and they confirmed this person",
                       isOn: $calledPublicNumber)
            }

            Section {
                Button {
                    Task {
                        isWorking = true
                        if await viewModel.approve(application, calledPublicNumber: calledPublicNumber) { dismiss() }
                        isWorking = false
                    }
                } label: {
                    Label("Approve as verified pharmacy", systemImage: "checkmark.seal")
                        .frame(maxWidth: .infinity)
                }
                .disabled(isWorking || !VerificationChecklist.canApprove(application,
                                                                       calledPublicNumber: calledPublicNumber))
            } footer: {
                Text("Approve stays disabled until every check is complete.")
            }

            Section("Reject") {
                TextField("Reason (shown to the applicant)", text: $rejectNote, axis: .vertical)
                Button("Reject application", role: .destructive) {
                    Task {
                        isWorking = true
                        if await viewModel.reject(application, note: rejectNote) { dismiss() }
                        isWorking = false
                    }
                }
                .disabled(isWorking || rejectNote.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}
