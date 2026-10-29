//
//  DirectionCard.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  DirectionsCard.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Bottom card: pharmacy, Drive/Walk, time + distance, steps. Optional ✕ to end directions.
struct DirectionsCard: View {
    @Bindable var viewModel: DirectionsViewModel
    var onClose: (() -> Void)? = nil
    var onRouteUpdated: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.pharmacy.name).font(.cardTitle)
                    Text(viewModel.pharmacy.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Theme.background, in: Circle())
                    }
                    .accessibilityLabel("End directions")
                }
            }

            Picker("Travel mode", selection: $viewModel.walking) {
                Label("Drive", systemImage: "car.fill").tag(false)
                Label("Walk", systemImage: "figure.walk").tag(true)
            }
            .pickerStyle(.segmented)

            switch viewModel.state {
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Finding the best route…").foregroundStyle(.secondary)
                }

            case .route(let route):
                HStack(spacing: 10) {
                    StatTile(value: Formatters.duration(route.travelTime),
                             label: viewModel.walking ? "walking" : "driving",
                             systemImage: "clock.fill", style: .card)
                    StatTile(value: Formatters.distance(route.distance),
                             label: "distance",
                             systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill",
                             style: .card)
                }
                if !route.steps.isEmpty {
                    DisclosureGroup("Steps (\(route.steps.count))") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(route.steps.indices, id: \.self) { index in
                                    Text("\(index + 1). \(route.steps[index])")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                    }
                    .tint(Theme.accent)
                }
                if let attribution = route.attribution {
                    Text(attribution)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }                                                  


            case .straightLine(let distance):
                Label("Road directions aren't available here. Straight-line distance: \(Formatters.distance(distance)).",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.warning)

            case .locationOff:
                Label("Turn on location to see directions.", systemImage: "location.slash")
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .onChange(of: viewModel.walking) { _, _ in
            Task {
                await viewModel.load()
                onRouteUpdated()          // let the map re-fit the new route
            }
        }
    }
}
