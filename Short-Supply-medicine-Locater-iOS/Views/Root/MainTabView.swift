//
//  MainTabView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

struct MainTabView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        VStack(spacing: 0) {
            if !services.connectivity.isOnline {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            TabView {
                NavigationStack {
                    HomeView(viewModel: HomeViewModel(
                        pharmacyService: services.pharmacies,
                        locationService: services.location))
                }
                .tabItem { Label("Home", systemImage: "house") }

                NavigationStack {
                    HelpFeedView(viewModel: services.makeHelpViewModel())
                }
                .tabItem { Label("Help", systemImage: "hand.raised") }

                NavigationStack {
                    PharmacyMapView(viewModel: MapViewModel(pharmacyService: services.pharmacies))
                }
                .tabItem { Label("Map", systemImage: "map") }

                NavigationStack {
                    MyRequestsView(viewModel: services.makeMyRequestsViewModel())
                }
                .tabItem { Label("My Requests", systemImage: "tray.full") }

                NavigationStack {
                    ProfileView(viewModel: services.makeProfileViewModel())
                }
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
            .tint(Theme.accent)
        }
        .animation(.default, value: services.connectivity.isOnline)
        .task {
            // Phase 7: check for new answers every 60 s while open
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await services.answerWatcher.checkForNewAnswers()
            }
        }
    }
}
