//
//  DirectionView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  DirectionsView.swift
//  Short-Supply-medicine-Locater-iOS
//

//
//  DirectionsView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import MapKit

/// Full-screen directions — used from Home and Source detail (screens without their own map).
struct DirectionsView: View {
    @State private var viewModel: DirectionsViewModel
    @State private var position: MapCameraPosition = .automatic

    init(viewModel: DirectionsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            RouteOverlay(pharmacy: viewModel.pharmacy,
                         route: viewModel.route,
                         straightLineFrom: viewModel.isStraightLine ? viewModel.userCoordinate : nil)
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .safeAreaInset(edge: .bottom) {
            DirectionsCard(viewModel: viewModel, onRouteUpdated: fitRoute)
        }
        .navigationTitle("Directions")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
            fitRoute()
        }
    }

    /// Zoom so me, the pharmacy and the route all fit.
    /// Fit me + pharmacy + route on screen, with a margin.
    private func fitRoute() {
        guard let rect = viewModel.mapRect else { return }
        withAnimation { position = .rect(rect) }
    }
}
