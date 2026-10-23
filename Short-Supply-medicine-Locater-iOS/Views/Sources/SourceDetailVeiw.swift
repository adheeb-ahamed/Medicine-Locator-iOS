//
//  SourceDetailVeiw.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// Everything about one report. On-site voting
///

struct SourceDetailView: View {
    
    @Environment(ServiceContainer.self) private var services
    
    let source: ScoredResponse
    let pharmacy: Pharmacy?

    var body: some View {
        let response = source.response
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(response.pharmacyName).font(.title2.bold())
                    Text(response.medicineName).foregroundStyle(.secondary)
                    HStack {
                        ConfidenceBadge(level: source.level)
                        Text("\(Int(source.score * 100))% confidence")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Report") {
                LabeledContent("Reported by",
                               value: response.source == .verifiedPharmacy ? "The pharmacy" : "A member")
                if response.source == .community && !response.wasOnSite {
                    NotConfirmedLabel()
                }
                LabeledContent("Reported") {
                    Text(response.createdAt, format: .relative(presentation: .named))
                }
                LabeledContent("Expires") {
                    Text(response.expiresAt, format: .relative(presentation: .named))
                }
            }

            Section("On-site checks") {
                LabeledContent("Still available", value: "\(response.stillAvailableCount)")
                LabeledContent("Sold out now", value: "\(response.soldOutCount)")
                LabeledContent("It was never here", value: "\(response.neverHereCount)")
            }
            OnSiteConfirmView(viewModel: services.makeOnSiteConfirmViewModel(
                response: response, pharmacy: pharmacy))
            

            if let pharmacy {
                Section {
                    LabeledContent("Address", value: pharmacy.address)
                    if let url = URL(string: "https://maps.apple.com/?daddr=\(pharmacy.latitude),\(pharmacy.longitude)") {
                        Link(destination: url) {
                            Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                        }
                    }
                }
            }

            Section {
                Text("Always call the pharmacy before travelling. Stock can change quickly.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Report")
        .navigationBarTitleDisplayMode(.inline)
    }
}
