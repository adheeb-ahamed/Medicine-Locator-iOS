//
//  ProfileView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// Profile tab (MVP item 2): who I am, my reputation, and links to everything else.
struct ProfileView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            // Header
            Section {
                HStack(spacing: 16) {
                    Image(systemName: app.isAnonymous ? "person.fill.questionmark" : "person.crop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.profile?.role.displayName ?? "Member").font(.headline)
                        Text(app.isAnonymous ? "Anonymous" : (app.profile?.email ?? ""))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack {
                        Text("\(viewModel.total)").font(.title.bold()).foregroundStyle(Theme.accent)
                        Text("reputation").font(.caption).foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
                .padding(.vertical, 4)
            }

            // Where reputation came from
            Section {
                if viewModel.recent.isEmpty {
                    Text("Help others by confirming stock on-site to earn reputation.")
                        .foregroundStyle(.secondary)
                }
                ForEach(viewModel.recent) { entry in
                    HStack {
                        Text(entry.reason.label)
                        Spacer()
                        Text(entry.points > 0 ? "+\(entry.points)" : "\(entry.points)")
                            .font(.body.monospacedDigit().weight(.semibold))
                            .foregroundStyle(entry.points > 0 ? Theme.success : Theme.danger)
                    }
                }
            } header: {
                Text("Recent reputation")
            } footer: {
                Text("Reputation is a trust signal only — there are no rewards or leaderboards.")
            }

            // Navigation
            Section {
                NavigationLink {
                    SettingsView(viewModel: services.makeSettingsViewModel())
                } label: { Label("Settings", systemImage: "gearshape") }

                NavigationLink {
                    AccountView(viewModel: services.makeAccountViewModel())
                } label: { Label("Account", systemImage: "person.badge.key") }
            }

            if let profile = app.profile {
                Section("Pharmacies") {
                    switch profile.role {
                    case .pharmacy:
                        NavigationLink {
                            PharmacyDashboardView(viewModel: services.makePharmacyDashboardViewModel(profile: profile))
                        } label: { Label("Pharmacy dashboard", systemImage: "cross.case") }
                    case .moderator:
                        NavigationLink {
                            ModeratorQueueView(viewModel: services.makeModeratorViewModel(moderatorID: profile.id))
                        } label: { Label("Verification queue", systemImage: "checkmark.seal") }
                    case .member:
                        NavigationLink {
                            VerifyPharmacyView(viewModel: services.makeVerifyPharmacyViewModel(profile: profile))
                        } label: { Label("I run a pharmacy", systemImage: "building.2") }
                    }
                }
            }

            Section("Safety & privacy") {
                NavigationLink { DataUseView() } label: {
                    Label("What we store", systemImage: "lock.doc")
                }
                NavigationLink { EmergencyInfoView() } label: {
                    Label("Emergency help", systemImage: "cross.case")
                        .foregroundStyle(Theme.danger)
                }
            }
        }
        .navigationTitle("Profile")
        .task { await viewModel.load() }
        .refreshable {
            await app.refreshProfile()
            await viewModel.load()
        }
    }
}