//
//  HomeView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI
import UIKit

/// The dashboard (MVP item 3).
struct HomeView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.openURL) private var openURL
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            // The two things anyone can do
            Section {
                NavigationLink {
                    SearchView(viewModel: services.makeSearchViewModel())
                } label: {
                    ActionCard(icon: "magnifyingglass",
                               title: "Find a medicine",
                               detail: "See where people found it, or ask people nearby.")
                }

                NavigationLink {
                    ContentUnavailableView("Help nearby is coming",
                                           systemImage: "hand.raised",
                                           description: Text("You'll be able to answer requests near you in Phase 6."))
                } label: {
                    ActionCard(icon: "hand.raised",
                               title: "Help nearby",
                               detail: "Tell others which pharmacy has their medicine.")
                }
            }

            Section("Pharmacies near you") {
                nearbyContent
            }
        }
        .navigationTitle("Medicine Locator")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var nearbyContent: some View {
        switch viewModel.locationState {
        case .unknown:
            VStack(alignment: .leading, spacing: 10) {
                Text("Turn on location to see licensed pharmacies near you.")
                Button("Use my location") {
                    Task { await viewModel.enableLocation() }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            }
            .padding(.vertical, 4)

        case .denied:
            VStack(alignment: .leading, spacing: 10) {
                Text("Location is off for Medicine Locator. You can still browse the map.")
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
            .padding(.vertical, 4)

        case .available:
            if viewModel.topNearby.isEmpty {
                Text("No licensed pharmacies within 10 km.")
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.topNearby) { item in
                NavigationLink {
                    PharmacyDetailView(pharmacy: item.pharmacy, distance: item.distance)
                } label: {
                    PharmacyRow(pharmacy: item.pharmacy, distance: item.distance)
                }
            }
        }

        if let error = viewModel.errorMessage {
            Text(error)
                .font(.footnote)
                .foregroundStyle(Theme.danger)
        }
    }
}
