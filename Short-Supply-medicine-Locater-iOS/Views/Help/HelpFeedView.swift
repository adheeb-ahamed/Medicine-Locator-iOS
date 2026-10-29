//
//  HelpFeedView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

//
//  HelpFeedView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import UIKit

/// Other people's open requests near me — hero + request cards.
struct HelpFeedView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.openURL) private var openURL
    @State private var viewModel: HelpViewModel

    init(viewModel: HelpViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var heroTitle: String {
        guard viewModel.locationState == .available else { return "Help people nearby" }
        switch viewModel.nearby.count {
        case 0:  return "No requests nearby"
        case 1:  return "1 person needs help"
        default: return "\(viewModel.nearby.count) people need help"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroHeader(title: heroTitle,
                           subtitle: "Tell them which licensed pharmacy has their medicine.")

                VStack(alignment: .leading, spacing: 14) {
                    content

                    if let error = viewModel.errorMessage {
                        Text(error).font(.footnote).foregroundStyle(Theme.danger)
                    }
                }
                .padding(20)
            }
        }
        .screenBackground()
        .navigationTitle("Help nearby")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)   // gradient shows through
        .toolbarColorScheme(.dark, for: .navigationBar)    // white title + back button on teal
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.locationState {
        case .unknown:
            VStack(alignment: .leading, spacing: 12) {
                Text("Turn on location to see what people near you are looking for.")
                Button("Use my location") {
                    Task { await viewModel.enableLocation() }
                }
                .buttonStyle(.tealPill)
            }
            .cardStyle()

        case .denied:
            VStack(alignment: .leading, spacing: 12) {
                Text("Location is off, so we can't show nearby requests.")
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                .buttonStyle(.tealPill)
            }
            .cardStyle()

        case .available:
            if viewModel.isLoading && viewModel.nearby.isEmpty {
                ProgressView().frame(maxWidth: .infinity)
            } else if viewModel.nearby.isEmpty {
                ContentUnavailableView("No requests nearby",
                                       systemImage: "hand.raised",
                                       description: Text("When someone near you needs a medicine, it shows here."))
                    .cardStyle()
            }

            ForEach(viewModel.nearby) { item in
                NavigationLink {
                    RespondView(viewModel: services.makeRespondViewModel(for: item.request))
                } label: {
                    HelpRequestCard(item: item)
                }
                .buttonStyle(.plain)
            }

            if !viewModel.nearby.isEmpty {
                Text("Only answer if you've seen it in stock or confirmed with the pharmacy.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}