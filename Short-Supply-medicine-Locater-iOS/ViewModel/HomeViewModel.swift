//
//  HomeViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation
import CoreLocation

/// Dashboard: nearby licensed pharmacies + location permission state.
@MainActor
@Observable
final class HomeViewModel {
    enum LocationState: Equatable {
        case unknown     // haven't asked yet
        case denied      // user said no
        case available   // we have a location
    }

    private(set) var nearby: [NearbyPharmacy] = []
    private(set) var locationState: LocationState = .unknown
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing

    init(pharmacyService: PharmacyServicing, locationService: LocationServicing) {
        self.pharmacyService = pharmacyService
        self.locationService = locationService
    }

    /// The dashboard only shows the closest 5.
    var topNearby: [NearbyPharmacy] { Array(nearby.prefix(5)) }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let pharmacies = try pharmacyService.loadPharmacies()

            switch locationService.authorizationStatus {
            case .notDetermined:
                locationState = .unknown            // show "Use my location" button
            case .denied, .restricted:
                locationState = .denied
                nearby = []
            default:
                let location = try await locationService.currentLocation()
                nearby = PharmacyFinder.nearby(pharmacies, from: location)
                locationState = .available
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Called from the "Use my location" button.
    func enableLocation() async {
        _ = await locationService.requestPermission()
        await load()
    }
}
