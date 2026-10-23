//
//  PharmacyMapView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI
import MapKit

/// All licensed pharmacies on a map (AF1: MapKit).
struct PharmacyMapView: View {
    @State private var viewModel: MapViewModel
    @State private var position: MapCameraPosition = .userLocation(fallback: .region(Self.colombo))
    @State private var selectedID: String?
    @State private var detailPharmacy: Pharmacy?

    /// Shown if we don't have the user's location.
    static let colombo = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    init(viewModel: MapViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()

            ForEach(viewModel.visiblePharmacies) { pharmacy in
                Marker(pharmacy.name,
                       systemImage: pharmacy.kind == .hospital ? "cross.fill" : "pills.fill",
                       coordinate: pharmacy.coordinate)
                    .tint(pharmacy.isVerified ? Theme.success : Theme.accent)
                    .tag(pharmacy.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .searchable(text: $viewModel.filterText, prompt: "Filter by name or district")
        .navigationTitle("Pharmacies")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedID) { _, id in
            detailPharmacy = viewModel.pharmacy(withID: id)
        }
        .sheet(item: $detailPharmacy, onDismiss: { selectedID = nil }) { pharmacy in
            NavigationStack {
                PharmacyDetailView(pharmacy: pharmacy)
            }
            .presentationDetents([.medium, .large])
        }
        .task { viewModel.load() }
    }
}
