//
//  PharmacyDetailView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Details for one pharmacy: header, facts card, Directions / Call.
struct PharmacyDetailView: View {
    let pharmacy: Pharmacy
    var distance: Double? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                detailsCard
                actionButtons
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle(pharmacy.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: pharmacy.kind == .hospital ? "cross.case.fill" : "pills.fill",
                     color: pharmacy.isVerified ? Theme.success : Theme.accent,
                     tint: pharmacy.isVerified ? Theme.successTint : Theme.accentTint,
                     size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(pharmacy.name)
                    .font(.system(.title2, design: .rounded, weight: .black))
                HStack(spacing: 10) {
                    Text(pharmacy.kind == .hospital ? "Hospital pharmacy" : "Pharmacy")
                        .foregroundStyle(.secondary)
                    if pharmacy.isVerified {
                        Label("Verified", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.success)
                    }
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 12) {
            row("Address", pharmacy.address, icon: "mappin.and.ellipse")
            Divider()
            row("District", pharmacy.district, icon: "map")
            if let distance {
                Divider()
                row("Distance", Formatters.distance(distance), icon: "location.fill")
            }
            Divider()
            row("Licence no.", pharmacy.id, icon: "doc.text")
        }
        .cardStyle()
    }

    private func row(_ title: String, _ value: String, icon: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .frame(width: 22)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            if let url = directionsURL {
                Link(destination: url) {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                }
                .buttonStyle(.tealPill)
            }
            if let phone = pharmacy.phone, let url = phoneURL(phone) {
                Link(destination: url) {
                    Label("Call", systemImage: "phone.fill")
                }
                .buttonStyle(.tealPill)
            }
        }
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