//
//  SourceDetailVeiw.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  SourceDetailVeiw.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import MapKit

/// Everything about one report: map, trust ring, on-site checks, call/directions,
/// history and the on-site voting card.
struct SourceDetailView: View {
    @Environment(ServiceContainer.self) private var services

    let source: ScoredResponse
    let pharmacy: Pharmacy?

    private var response: AvailabilityResponse { source.response }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let pharmacy {
                    map(for: pharmacy)
                }

                VStack(alignment: .leading, spacing: 20) {
                    header
                    trustCard
                    checksRow
                    actionButtons
                    history

                    OnSiteConfirmView(viewModel: services.makeOnSiteConfirmViewModel(
                        response: response, pharmacy: pharmacy))
                    

                    Text("Always call the pharmacy before travelling. Stock can change quickly.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(Theme.background,
                            in: UnevenRoundedRectangle(topLeadingRadius: 28,
                                                       topTrailingRadius: 28,
                                                       style: .continuous))
                .padding(.top, pharmacy == nil ? 0 : -28)   // "sheet" slides over the map
            }
        }
        .screenBackground()
        .navigationTitle("Report")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Map

    private func map(for pharmacy: Pharmacy) -> some View {
        Map(initialPosition: .region(MKCoordinateRegion(center: pharmacy.coordinate,
                                                        latitudinalMeters: 600,
                                                        longitudinalMeters: 600))) {
            Marker(pharmacy.name, systemImage: "cross.fill", coordinate: pharmacy.coordinate)
                .tint(Theme.accent)
        }
        .frame(height: 240)
        .allowsHitTesting(false)            // just a picture; the Map tab is for exploring
        .accessibilityHidden(true)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(response.pharmacyName)
                .font(.system(.title, design: .rounded, weight: .black))
            Text(response.medicineName)
                .foregroundStyle(.secondary)
            SourceTag(response: response)
            if let pharmacy {
                Label(pharmacy.address, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Big ring + how long the report stays visible.
    private var trustCard: some View {
        HStack(spacing: 18) {
            ConfidenceRing(score: source.score, size: 96, showsLevel: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(source.level.label) confidence")
                    .font(.cardTitle)
                Text(Formatters.timeLeft(until: response.expiresAt))
                    .font(.bigNumber)
                    .foregroundStyle(Theme.accent)
                if response.source == .community {
                    Text("Each on-site \u{201C}Still available\u{201D} adds 2 hours, up to 12 hours.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }

    /// The three on-site vote counts.
    private var checksRow: some View {
        HStack(spacing: 10) {
            StatTile(value: "\(response.stillAvailableCount)", label: "still available",
                     systemImage: "checkmark.circle.fill", style: .card)
            StatTile(value: "\(response.soldOutCount)", label: "sold out now",
                     systemImage: "xmark.circle", style: .card)
            StatTile(value: "\(response.neverHereCount)", label: "never here",
                     systemImage: "exclamationmark.triangle", style: .card)
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if let pharmacy {
            HStack(spacing: 12) {
                if let phone = pharmacy.phone,
                   let url = URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })") {
                    Link(destination: url) {
                        Label("Call", systemImage: "phone.fill")
                    }
                    .buttonStyle(.tealPill)
                }
                NavigationLink {
                    DirectionsView(viewModel: services.makeDirectionsViewModel(to: pharmacy))
                } label: {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                }
                .buttonStyle(.tealPill)
            }
        }
    }

    /// Simple timeline built only from data we really have.
    private var history: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("History").font(.sectionTitle)

            timelineRow(icon: response.source == .verifiedPharmacy ? "checkmark.seal.fill" : "person.fill",
                        color: Theme.accent,
                        title: response.source == .verifiedPharmacy ? "Posted by the pharmacy" : "Reported by a member",
                        date: response.createdAt)

            if response.stillAvailableCount > 0 {
                timelineRow(icon: "checkmark.circle.fill",
                            color: Theme.success,
                            title: "Confirmed on-site \(response.stillAvailableCount)×",
                            date: nil)
            }

            timelineRow(icon: "clock.fill",
                        color: Theme.tertiary,
                        title: "Listed until \(response.expiresAt.formatted(date: .omitted, time: .shortened))",
                        date: nil)
        }
        .cardStyle()
    }

    private func timelineRow(icon: String, color: Color, title: String, date: Date?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.weight(.semibold))
                if let date {
                    Text(date, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
