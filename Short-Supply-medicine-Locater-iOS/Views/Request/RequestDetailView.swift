//
//  RequestDetailView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// One of my requests: its answers + found / close / renew.
struct RequestDetailView: View {
    let request: MedicineRequest
    let myRequests: MyRequestsViewModel
    @State private var sources: SourcesViewModel
    @State private var showingFoundOptions = false
    @Environment(\.dismiss) private var dismiss

    init(request: MedicineRequest, myRequests: MyRequestsViewModel, sources: SourcesViewModel) {
        self.request = request
        self.myRequests = myRequests
        _sources = State(initialValue: sources)
    }

    var body: some View {
        let status = request.effectiveStatus()

        List {
            Section {
                LabeledContent("Medicine", value: request.medicine.displayName)
                LabeledContent("Area", value: request.areaName)
                LabeledContent("Status", value: status.label)
                LabeledContent(status == .expired ? "Expired" : "Expires") {
                    Text(request.expiresAt, format: .relative(presentation: .named))
                }
            }

            SourcesListView(viewModel: sources,
                            emptyMessage: "No answers yet. People in \(request.areaName) can see your request.")

            if status == .open {
                Section {
                    Button("I found it") { showingFoundOptions = true }
                        .foregroundStyle(Theme.success)
                    Button("I don't need it anymore", role: .destructive) {
                        Task { await myRequests.close(request); dismiss() }
                    }
                }
            }

            if status == .expired || status == .closed {
                Section {
                    Button("Ask again for 7 days") {
                        Task { await myRequests.renew(request); dismiss() }
                    }
                }
            }
        }
        .navigationTitle(request.medicine.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await sources.load() }
        .confirmationDialog("Where did you find it?",
                            isPresented: $showingFoundOptions,
                            titleVisibility: .visible) {
            ForEach(sources.sources) { source in
                Button(source.response.pharmacyName) {
                    Task { await myRequests.markFound(request, response: source.response); dismiss() }
                }
            }
            Button("Somewhere else") {
                Task { await myRequests.markFound(request, response: nil); dismiss() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
