//
//  RequestDetailView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  RequestDetailView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// One of my requests: header card, its answers, and found / close / renew buttons.
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
            headerCard(status: status)
                .cardRow()

            SourcesListView(viewModel: sources,
                            emptyMessage: "No answers yet. People in \(request.areaName) can see your request.")

            // Each button in its OWN row — two buttons in one List row would both fire on tap.
            if status == .open {
                Button {
                    showingFoundOptions = true
                } label: {
                    Label("I found it", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.primaryPill)
                .cardRow()

                Button("I don't need it anymore", role: .destructive) {
                    Task { await myRequests.close(request); dismiss() }
                }
                .frame(maxWidth: .infinity)
                .cardRow()
            }

            if status == .expired || status == .closed {
                Button {
                    Task { await myRequests.renew(request); dismiss() }
                } label: {
                    Label("Ask again for 7 days", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.tealPill)
                .cardRow()
            }
        }
        .screenBackground()
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

    private func headerCard(status: MedicineRequest.Status) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                IconTile(systemImage: "pills.fill", size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.medicine.displayName)
                        .font(.system(.title2, design: .rounded, weight: .black))
                    StatusChip(status: status)
                }
            }
            Divider()
            HStack {
                Label(request.areaName, systemImage: "mappin.and.ellipse")
                Spacer()
                Label {
                    Text("\(status == .expired ? "Expired" : "Expires") \(request.expiresAt, format: .relative(presentation: .named))")
                } icon: {
                    Image(systemName: "clock")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}