//
//  PharmacyMapView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  PharmacyMapView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import MapKit

/// All licensed pharmacies on a map (AF1: MapKit) with filter chips and a card carousel.
/// Pin ↔ card stay in sync: tap a pin → its card scrolls in; swipe a card → its pin is selected.
struct PharmacyMapView: View {
    @State private var viewModel: MapViewModel
    @State private var position: MapCameraPosition = .userLocation(fallback: .region(Self.colombo))
    @State private var selectedID: String?        // selected pin
    @State private var carouselID: String?        // card currently centred in the carousel
    @State private var detailPharmacy: Pharmacy?  // sheet

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
                Annotation(pharmacy.name, coordinate: pharmacy.coordinate) {
                    PharmacyPin(pharmacy: pharmacy, isSelected: selectedID == pharmacy.id)
                }
                .annotationTitles(.hidden)        // the carousel shows names instead
                .tag(pharmacy.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top) { filterChips }
        .safeAreaInset(edge: .bottom) { carousel }
        .searchable(text: $viewModel.filterText, prompt: "Filter by name or district")
        .navigationTitle("Pharmacies")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedID) { _, id in
            pinSelected(id)
        }
        .onChange(of: carouselID) { _, id in
            cardScrolled(to: id)
        }
        .sheet(item: $detailPharmacy) { pharmacy in
            NavigationStack {
                PharmacyDetailView(pharmacy: pharmacy, distance: viewModel.distance(to: pharmacy))
            }
            .presentationDetents([.medium, .large])
        }
        .task { await viewModel.load() }
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MapViewModel.Filter.allCases) { filter in
                    let isOn = viewModel.filter == filter
                    Button {
                        viewModel.filter = filter
                    } label: {
                        Label(filter.title, systemImage: filter.systemImage)
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(isOn ? .white : Theme.accent)
                            .background(isOn ? Theme.accentFill : Theme.card,
                                        in: RoundedRectangle(cornerRadius: Theme.Radius.chip, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Carousel

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.carouselPharmacies) { pharmacy in
                    Button {
                        detailPharmacy = pharmacy
                    } label: {
                        MapPharmacyCard(pharmacy: pharmacy,
                                        distance: viewModel.distance(to: pharmacy),
                                        isSelected: selectedID == pharmacy.id)
                    }
                    .buttonStyle(.plain)
                    .id(pharmacy.id)
                }
            }
            .scrollTargetLayout()               // each card is a "snap" point
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollTargetBehavior(.viewAligned)     // swipe snaps card by card
        .scrollPosition(id: $carouselID)        // tells us which card is centred
    }

    // MARK: - Sync pin ↔ card

    /// Pin tapped: scroll its card into view, or open details if it isn't in the carousel.
    private func pinSelected(_ id: String?) {
        guard let id else { return }
        if viewModel.carouselPharmacies.contains(where: { $0.id == id }) {
            withAnimation { carouselID = id }
        } else {
            detailPharmacy = viewModel.pharmacy(withID: id)
        }
    }

    /// Card swiped: select its pin and move the map to it.
    private func cardScrolled(to id: String?) {
        guard let id, let pharmacy = viewModel.pharmacy(withID: id) else { return }
        selectedID = id
        withAnimation(.easeInOut) {
            position = .region(MKCoordinateRegion(center: pharmacy.coordinate,
                                                  latitudinalMeters: 1500,
                                                  longitudinalMeters: 1500))
        }
    }
}