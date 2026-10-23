//
//  HelpFeedView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI
import UIKit

/// Other people's open requests near me.
struct HelpFeedView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.openURL) private var openURL
    @State private var viewModel: HelpViewModel

    init(viewModel: HelpViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            switch viewModel.locationState {
            case .unknown:
                Section {
                    Text("Turn on location to see what people near you are looking for.")
                    Button("Use my location") {
                        Task { await viewModel.enableLocation() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                }
            case .denied:
                Section {
                    Text("Location is off, so we can't show nearby requests.")
                        .foregroundStyle(.secondary)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                }
            case .available:
                Section {
                    ForEach(viewModel.nearby) { item in
                        NavigationLink {
                            RespondView(viewModel: services.makeRespondViewModel(for: item.request))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.request.medicine.displayName)
                                    .font(.body.weight(.medium))
                                HStack {
                                    Label(item.request.areaName, systemImage: "mappin.and.ellipse")
                                    Spacer()
                                    Text("~\(Formatters.distance(item.distance))")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                } footer: {
                    Text("Only answer if you've seen it in stock or confirmed with the pharmacy.")
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
            }
        }
        .overlay {
            if viewModel.locationState == .available && viewModel.nearby.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No requests nearby",
                                       systemImage: "hand.raised",
                                       description: Text("When someone near you needs a medicine, it shows here."))
            }
        }
        .navigationTitle("Help nearby")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
