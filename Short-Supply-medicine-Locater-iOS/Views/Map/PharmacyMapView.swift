//
//  PharmacyMapView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import MapKit

/// Licensed pharmacies near me (AF1: MapKit) with filter chips and a card carousel.
/// Tapping Directions draws the route on THIS map — no second map.
struct PharmacyMapView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: MapViewModel
    @State private var position: MapCameraPosition = .region(Self.colombo)
    @State private var selectedID: String?               // selected pin
    @State private var carouselID: String?               // centred card
    @State private var detailPharmacy: Pharmacy?         // details sheet
    @State private var directions: DirectionsViewModel?  // not nil = route mode

    /// Shown until we know where the user is.
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

            // Normal mode: all nearby pins. Route mode: only the destination (from RouteOverlay).
            ForEach(directions == nil ? viewModel.visiblePharmacies : []) { pharmacy in
                Annotation(pharmacy.name, coordinate: pharmacy.coordinate) {
                    PharmacyPin(pharmacy: pharmacy, isSelected: selectedID == pharmacy.id)
                }
                .annotationTitles(.hidden)
                .tag(pharmacy.id)
            }

            if let directions {
                RouteOverlay(pharmacy: directions.pharmacy,
                             route: directions.route,
                             straightLineFrom: directions.isStraightLine ? directions.userCoordinate : nil)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top) {
            if directions == nil { filterChips }
        }
        .safeAreaInset(edge: .bottom) {
            if let directions {
                DirectionsCard(viewModel: directions,
                               onClose: endDirections,
                               onRouteUpdated: fitRoute)
            } else {
                carousel
            }
        }
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
                PharmacyDetailView(pharmacy: pharmacy,
                                   distance: viewModel.distance(to: pharmacy)) {
                    startDirections(to: pharmacy)       // Directions → this map
                }
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            await viewModel.load()
            zoomToUser()
        }
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
        .fixedSize(horizontal: false, vertical: true)   // only as tall as the chips
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
            .scrollTargetLayout()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $carouselID)
        .fixedSize(horizontal: false, vertical: true)   // THE ZOOM FIX: only as tall as the cards
    }

    // MARK: - Camera

    /// About 4 km around me.
    private func zoomToUser() {
        guard let here = viewModel.userLocation else { return }
        withAnimation {
            position = .region(MKCoordinateRegion(center: here.coordinate,
                                                  latitudinalMeters: 4000,
                                                  longitudinalMeters: 4000))
        }
    }

    /// Fit me + pharmacy + route on screen.
    /// Fit me + pharmacy + route on screen, with a margin.
    private func fitRoute() {
        guard let rect = directions?.mapRect else { return }
        withAnimation { position = .rect(rect) }
    }

    // MARK: - Directions on this map

    private func startDirections(to pharmacy: Pharmacy) {
        detailPharmacy = nil                 // close the sheet
        selectedID = nil
        let route = services.makeDirectionsViewModel(to: pharmacy)
        directions = route
        Task {
            await route.load()
            fitRoute()
        }
    }

    private func endDirections() {
        directions = nil
        zoomToUser()
    }

    // MARK: - Sync pin ↔ card

    private func pinSelected(_ id: String?) {
        guard let id else { return }
        if viewModel.carouselPharmacies.contains(where: { $0.id == id }) {
            withAnimation { carouselID = id }
        } else {
            detailPharmacy = viewModel.pharmacy(withID: id)
        }
    }

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
