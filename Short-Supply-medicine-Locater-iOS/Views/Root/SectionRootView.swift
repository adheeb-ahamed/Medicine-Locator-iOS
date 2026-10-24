//
//  SectionRootView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// Builds the first screen of a section. Used by BOTH the tab bar and the sidebar.
struct SectionRootView: View {
    let section: AppSection
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        switch section {
        case .home:
            HomeView(viewModel: services.makeHomeViewModel())
        case .help:
            HelpFeedView(viewModel: services.makeHelpViewModel())
        case .map:
            PharmacyMapView(viewModel: services.makeMapViewModel())
        case .requests:
            MyRequestsView(viewModel: services.makeMyRequestsViewModel())
        case .profile:
            ProfileView(viewModel: services.makeProfileViewModel())
        }
    }
}