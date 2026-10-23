//
//  PharmacyDetailView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// Details for one pharmacy. Availability reports are added in Phases 5–6.
struct PharmacyDetailView: View {
    let pharmacy: Pharmacy
    var distance: Double? = nil

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pharmacy.name)
                        .font(.title2.bold())
                    HStack(spacing: 12) {
                        Label(pharmacy.kind == .hospital ? "Hospital pharmacy" : "Pharmacy",
                              systemImage: pharmacy.kind == .hospital ? "cross.case" : "pills")
                        if pharmacy.isVerified {
                            Label("Verified", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Theme.success)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            Section("Details") {
                LabeledContent("Address", value: pharmacy.address)
                LabeledContent("District", value: pharmacy.district)
                if let distance {
                    LabeledContent("Distance", value: Formatters.distance(distance))
                }
                LabeledContent("Licence no.", value: pharmacy.id)
            }

            Section {
                if let url = directionsURL {
                    Link(destination: url) {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                    }
                }
                if let phone = pharmacy.phone, let url = phoneURL(phone) {
                    Link(destination: url) {
                        Label("Call \(phone)", systemImage: "phone")
                    }
                }
            }

            Section {
                Text("Availability reports for this pharmacy will appear here.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(pharmacy.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Opens Apple Maps with directions to the pharmacy.
    private var directionsURL: URL? {
        URL(string: "https://maps.apple.com/?daddr=\(pharmacy.latitude),\(pharmacy.longitude)")
    }

    /// "tel:" link that starts a phone call (digits and + only).
    private func phoneURL(_ phone: String) -> URL? {
        URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })")
    }
}
