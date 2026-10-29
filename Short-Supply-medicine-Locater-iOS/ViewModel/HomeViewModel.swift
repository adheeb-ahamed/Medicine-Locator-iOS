//
//  HomeViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  HomeViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation
import Observation
import CoreLocation

/// Dashboard: nearby pharmacies, my open requests, how many people nearby need help.
@MainActor
@Observable
final class HomeViewModel {
    enum LocationState: Equatable {
        case unknown     // haven't asked yet
        case denied      // user said no
        case available   // we have a location
    }

    private(set) var nearby: [NearbyPharmacy] = []
    private(set) var myActiveRequests: [MedicineRequest] = []   // NEW: "You're looking for"
    private(set) var helpNearbyCount = 0                        // NEW: coral help card + stat tile
    private(set) var locationState: LocationState = .unknown
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing
    private let requestService: RequestServicing     // NEW
    private let authService: AuthServicing           // NEW
    private let summaryStore: RequestsSummaryStore

    init(pharmacyService: PharmacyServicing,
         locationService: LocationServicing,
         requestService: RequestServicing,
         authService: AuthServicing,
         summaryStore: RequestsSummaryStore = RequestsSummaryStore() ){
        self.pharmacyService = pharmacyService
        self.locationService = locationService
        self.requestService = requestService
        self.authService = authService
        self.summaryStore = summaryStore
        
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
                await loadHelpCount(near: location)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        await loadMyRequests()      // doesn't need location, so it always runs
    }

    /// Called from the "Use my location" button.
    func enableLocation() async {
        _ = await locationService.requestPermission()
        await load()
    }

    /// "Good morning" / "Good afternoon" / "Good evening" for the hero.
    /// `date` is a parameter so tests can pass a fixed time.
    func greeting(at date: Date = .now, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case 5..<12:  "Good morning"
        case 12..<17: "Good afternoon"
        default:      "Good evening"
        }
    }

    // MARK: - Private

    /// My requests that are still open and not expired.
    private func loadMyRequests() async {
        guard let userID = authService.currentUserID else { return }
        do {
            myActiveRequests = try await requestService.requests(ownedBy: userID)
                .filter { $0.isActive() }
            summaryStore.save(.make(from: myActiveRequests))
        } catch {
            myActiveRequests = []   // Home still works offline; My Requests tab shows the error
        }
    }

    /// Re-uses the same HelpFeed rule as the Help tab, so the numbers always match.
    private func loadHelpCount(near location: CLLocation) async {
        guard let userID = authService.currentUserID else { return }
        let open = (try? await requestService.openRequests()) ?? []
        helpNearbyCount = HelpFeed.nearby(open, from: location, excluding: userID).count
    }
}
