//
//  HomeView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  HomeView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import UIKit

/// The dashboard (MVP item 3) — redesigned.
/// Layout top to bottom: hero → search pill → my requests → help card → nearby pharmacies.
struct HomeView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppViewModel.self) private var app
    @Environment(\.openURL) private var openURL
    @State private var viewModel: HomeViewModel

    // Scan → search flow
    @State private var showingScanner = false
    @State private var scannedSearch: SearchViewModel?
    @State private var showingScannedSearch = false

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, -28)        // pull the pill up so it overlaps the hero edge

                VStack(alignment: .leading, spacing: 24) {
                    myRequestsSection

                    NavigationLink {
                        HelpFeedView(viewModel: services.makeHelpViewModel())
                    } label: {
                        HelpNearbyCard(count: viewModel.helpNearbyCount)
                    }
                    .buttonStyle(.plain)

                    nearbySection

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Theme.danger)
                    }
                }
                .padding(20)
            }
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)      // the hero replaces the big title
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .sheet(isPresented: $showingScanner, onDismiss: openScannedSearch) {
            NavigationStack {
                ScanView(viewModel: services.makeScanViewModel()) { name, _ in
                    let search = services.makeSearchViewModel()
                    search.query = name
                    search.submit()                 // search straight away
                    scannedSearch = search
                }
            }
        }
        .navigationDestination(isPresented: $showingScannedSearch) {
            if let scannedSearch {
                SearchView(viewModel: scannedSearch)
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        HeroHeader(eyebrow: viewModel.greeting(), title: "Find medicine") {
            VStack(alignment: .leading, spacing: 14) {
                identityChip
                HStack(spacing: 12) {
                    StatTile(value: "\(viewModel.myActiveRequests.count)",
                             label: "your open requests",
                             systemImage: "tray.full.fill")
                    StatTile(value: viewModel.locationState == .available
                                    ? "\(viewModel.helpNearbyCount)" : "–",
                             label: "people nearby need help",
                             systemImage: "person.2.fill")
                }
            }
            .padding(.bottom, 24)                  // room for the overlapping search pill
        }
    }

    /// "Anonymous" or the role name — reminds users their identity isn't shared.
    private var identityChip: some View {
        Label(app.isAnonymous ? "Anonymous" : (app.profile?.role.displayName ?? "Member"),
              systemImage: app.isAnonymous ? "eye.slash.fill" : "person.crop.circle.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.16), in: Capsule())
    }

    // MARK: - Search pill

    private var searchBar: some View {
        HStack(spacing: 10) {
            NavigationLink {
                SearchView(viewModel: services.makeSearchViewModel())
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.accent)
                    Text("Search a medicine name")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.leading, 18)
                .frame(height: Theme.buttonHeight)
                .contentShape(Rectangle())         // whole area is tappable, not just the text
            }
            .buttonStyle(.plain)

            Button {
                scannedSearch = nil
                showingScanner = true
            } label: {
                Image(systemName: "text.viewfinder")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.coral, in: Circle())
            }
            .accessibilityLabel("Scan medicine box")
            .padding(.trailing, 6)
        }
        .background(Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
    }

    /// After the scanner sheet closes, open the search results if something was picked.
    private func openScannedSearch() {
        if scannedSearch != nil { showingScannedSearch = true }
    }

    // MARK: - My requests

    @ViewBuilder
    private var myRequestsSection: some View {
        if !viewModel.myActiveRequests.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("You're looking for").font(.sectionTitle)

                ForEach(viewModel.myActiveRequests.prefix(2)) { request in
                    NavigationLink {
                        RequestDetailView(request: request,
                                          myRequests: services.makeMyRequestsViewModel(),
                                          sources: services.makeSourcesViewModel(
                                              .request(id: request.id, medicineKey: request.medicine.key)))
                    } label: {
                        RequestRow(request: request)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Nearby pharmacies

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pharmacies near you").font(.sectionTitle)
            VStack(alignment: .leading, spacing: 0) {
                nearbyContent
            }
            .cardStyle()
        }
    }

    @ViewBuilder
    private var nearbyContent: some View {
        switch viewModel.locationState {
        case .unknown:
            VStack(alignment: .leading, spacing: 12) {
                Text("Turn on location to see licensed pharmacies near you.")
                Button("Use my location") {
                    Task { await viewModel.enableLocation() }
                }
                .buttonStyle(.tealPill)
            }

        case .denied:
            VStack(alignment: .leading, spacing: 12) {
                Text("Location is off for Medicine Locator. You can still browse the map.")
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.tealPill)
            }

        case .available:
            if viewModel.topNearby.isEmpty {
                Text("No licensed pharmacies within 10 km.")
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.topNearby) { item in
                if item.id != viewModel.topNearby.first?.id {
                    Divider()                       // line between rows, not above the first
                }
                NavigationLink {
                    PharmacyDetailView(pharmacy: item.pharmacy, distance: item.distance)
                } label: {
                    PharmacyRow(pharmacy: item.pharmacy, distance: item.distance)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}