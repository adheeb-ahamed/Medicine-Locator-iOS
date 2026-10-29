//
//  ProfileView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


//
//  ProfileView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Profile tab (MVP item 2): level hero, save-points nudge, reputation history, menus.
struct ProfileView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 24) {
                    if app.isAnonymous && viewModel.total > 0 {
                        saveNudge
                    }
                    reputationCard
                    menus
                }
                .padding(20)
            }
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .refreshable {
            await app.refreshProfile()
            await viewModel.load()
        }
    }

    // MARK: - Hero with level ring

    private var hero: some View {
        HeroHeader(eyebrow: app.isAnonymous ? "Anonymous member" : (app.profile?.email ?? "Member"),
                   title: viewModel.level.title) {
            HStack(spacing: 18) {
                LevelRing(progress: viewModel.levelProgress, points: viewModel.total)

                VStack(alignment: .leading, spacing: 8) {
                    Text(app.profile?.role.displayName ?? "Member")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.16), in: Capsule())

                    Group {
                        if let toNext = viewModel.pointsToNextLevel, let next = viewModel.level.next {
                            Text("\(toNext) points to \(next.title)")
                        } else {
                            Text("Highest level reached")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(.bottom, 4)
        }
    }

    // MARK: - Coral nudge (anonymous users only)

    private var saveNudge: some View {
        NavigationLink {
            AccountView(viewModel: services.makeAccountViewModel())
        } label: {
            HStack(spacing: 14) {
                IconTile(systemImage: "lock.shield.fill", color: .white, tint: Theme.coral, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Save your \(viewModel.total) points")
                        .font(.cardTitle)
                    Text("Link an email so you keep your reputation if you change phones.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.coralTint,
                        in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reputation history

    private var reputationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent reputation").font(.sectionTitle)

            VStack(spacing: 12) {
                if viewModel.recent.isEmpty {
                    Text("Help others by confirming stock on-site to earn reputation.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForEach(viewModel.recent) { entry in
                    HStack(spacing: 12) {
                        IconTile(systemImage: icon(for: entry.reason),
                                 color: entry.points > 0 ? Theme.success : Theme.danger,
                                 tint: entry.points > 0 ? Theme.successTint : Theme.dangerTint,
                                 size: 34)
                        Text(entry.reason.label)
                            .font(.subheadline)
                        Spacer()
                        Text(entry.points > 0 ? "+\(entry.points)" : "\(entry.points)")
                            .font(.system(.headline, design: .rounded, weight: .black))
                            .foregroundStyle(entry.points > 0 ? Theme.success : Theme.danger)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .cardStyle()

            Text("Reputation is a trust signal only — there are no rewards or leaderboards.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func icon(for event: ReputationEvent) -> String {
        switch event {
        case .confirmedOnSite:     "location.fill"
        case .responseMarkedFound: "hands.sparkles.fill"
        case .responseProvedFalse: "exclamationmark.triangle.fill"
        }
    }

    // MARK: - Menus

    @ViewBuilder
    private var menus: some View {
        menuCard("You") {
            NavigationLink {
                SettingsView(viewModel: services.makeSettingsViewModel())
            } label: { menuRow("Settings", icon: "gearshape.fill") }
            Divider()
            NavigationLink {
                AccountView(viewModel: services.makeAccountViewModel())
            } label: { menuRow("Account", icon: "person.badge.key.fill") }
        }

        if let profile = app.profile {
            menuCard("Pharmacies") {
                switch profile.role {
                case .pharmacy:
                    NavigationLink {
                        PharmacyDashboardView(viewModel: services.makePharmacyDashboardViewModel(profile: profile))
                    } label: { menuRow("Pharmacy dashboard", icon: "cross.case.fill") }
                case .moderator:
                    NavigationLink {
                        ModeratorQueueView(viewModel: services.makeModeratorViewModel(moderatorID: profile.id))
                    } label: { menuRow("Verification queue", icon: "checkmark.seal.fill") }
                case .member:
                    NavigationLink {
                        VerifyPharmacyView(viewModel: services.makeVerifyPharmacyViewModel(profile: profile))
                    } label: { menuRow("I run a pharmacy", icon: "building.2.fill") }
                }
            }
        }

        menuCard("Safety & privacy") {
            NavigationLink { DataUseView() } label: {
                menuRow("What we store", icon: "lock.doc.fill")
            }
            Divider()
            NavigationLink { EmergencyInfoView() } label: {
                menuRow("Emergency help", icon: "cross.case.fill",
                        color: Theme.danger, tint: Theme.dangerTint)
            }
        }
    }

    /// A titled white card that groups menu rows.
    private func menuCard<Content: View>(_ title: String,
                                         @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.sectionTitle)
            VStack(spacing: 4) {
                content()
            }
            .buttonStyle(.plain)
            .cardStyle(padding: 12)
        }
    }

    /// Icon tile + title + chevron.
    private func menuRow(_ title: String, icon: String,
                         color: Color = Theme.accent, tint: Color = Theme.accentTint) -> some View {
        HStack(spacing: 12) {
            IconTile(systemImage: icon, color: color, tint: tint, size: 34)
            Text(title)
                .foregroundStyle(color == Theme.danger ? Theme.danger : Color.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}