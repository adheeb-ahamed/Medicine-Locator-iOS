//
//  MainTabView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// The main app after unlock. Home is a placeholder until Phase 4.
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentUnavailableView(
                    "Home is coming next",
                    systemImage: "hammer",
                    description: Text("Search, requests and the map arrive in Phase 4.")
                )
                .navigationTitle("Home")
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                AccountView()
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(Theme.accent)
    }
}
