//
//  MapViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  MapViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation
import Observation
import CoreLocation

/// Map of all licensed pharmacies: text filter, filter chips, nearest-first carousel.
@MainActor
@Observable
final class MapViewModel {

    /// The chips at the top of the map.
    enum Filter: String, CaseIterable, Identifiable {
        case all, hospitals, verified

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all:       "All"
            case .hospitals: "Hospitals"
            case .verified:  "Verified"
            }
        }

        var systemImage: String {
            switch self {
            case .all:       "square.grid.2x2.fill"
            case .hospitals: "cross.case.fill"
            case .verified:  "checkmark.seal.fill"
            }
        }
    }

    var filterText = ""
    var filter: Filter = .all
    private(set) var pharmacies: [Pharmacy] = []
    private(set) var userLocation: CLLocation?
    private(set) var errorMessage: String?

    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing

    init(pharmacyService: PharmacyServicing, locationService: LocationServicing) {
        self.pharmacyService = pharmacyService
        self.locationService = locationService
    }

    /// Pins on the map. Recalculated automatically when the text, chip or data change.
    var visiblePharmacies: [Pharmacy] {
        let matched = PharmacyFinder.matching(filterText, in: pharmacies)
        switch filter {
        case .all:       return matched
        case .hospitals: return matched.filter { $0.kind == .hospital }
        case .verified:  return matched.filter(\.isVerified)
        }
    }

    /// Bottom cards: the 10 closest visible pharmacies (or the first 10 if we have no location).
    var carouselPharmacies: [Pharmacy] {
        guard let userLocation else { return Array(visiblePharmacies.prefix(10)) }
        let sorted = visiblePharmacies.sorted {
            $0.distance(from: userLocation) < $1.distance(from: userLocation)
        }
        return Array(sorted.prefix(10))
    }

    /// Metres from the user, or nil if location is off.
    func distance(to pharmacy: Pharmacy) -> Double? {
        userLocation.map { pharmacy.distance(from: $0) }
    }

    func load() async {
        do {
            pharmacies = try pharmacyService.loadPharmacies()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        // Only use location if the user already allowed it — the map never asks by itself.
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            userLocation = try? await locationService.currentLocation()
        default:
            userLocation = nil
        }
    }

    func pharmacy(withID id: String?) -> Pharmacy? {
        pharmacies.first { $0.id == id }
    }
}