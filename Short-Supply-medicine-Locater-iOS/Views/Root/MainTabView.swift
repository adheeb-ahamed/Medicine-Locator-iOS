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
        TabView {
            NavigationStack {
                HomeView(viewModel: HomeViewModel(
                    pharmacyService: services.pharmacies,
                    locationService: services.location
                ))
            }
            .tabItem { Label("Home", systemImage: "house") }
            
            NavigationStack {
                HelpFeedView(viewModel: services.makeHelpViewModel())
            }
            .tabItem { Label("Help", systemImage: "hand.raised") }

            NavigationStack {
                PharmacyMapView(viewModel: MapViewModel(
                    pharmacyService: services.pharmacies
                ))
            }
            .tabItem { Label("Map", systemImage: "map") }
            
            NavigationStack {
                MyRequestsView(viewModel: services.makeMyRequestsViewModel())
            }
            .tabItem { Label("My Requests", systemImage: "tray.full") }

            NavigationStack {
                AccountView()
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(Theme.accent)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await services.answerWatcher.checkForNewAnswers()
            }
        }
    }
}
