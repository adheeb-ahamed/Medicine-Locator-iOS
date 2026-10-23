//
//  RespondViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation
import CoreLocation

/// "Which licensed pharmacy has it?" for one request.
@MainActor
@Observable
final class RespondViewModel {
    let request: MedicineRequest
    private(set) var options: [NearbyPharmacy] = []
    var selected: NearbyPharmacy?
    private(set) var currentLocation: CLLocation?
    private(set) var isSending = false
    private(set) var errorMessage: String?
    private(set) var didSend = false

    private let responseService: ResponseServicing
    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing
    private let authService: AuthServicing

    init(request: MedicineRequest,
         responseService: ResponseServicing,
         pharmacyService: PharmacyServicing,
         locationService: LocationServicing,
         authService: AuthServicing) {
        self.request = request
        self.responseService = responseService
        self.pharmacyService = pharmacyService
        self.locationService = locationService
        self.authService = authService
    }

    // MARK: - Derived

    var isOwnRequest: Bool { request.ownerID == authService.currentUserID }

    /// On-site = I'm within 100 m of the pharmacy I picked.
    var isOnSite: Bool {
        guard let selected, let currentLocation else { return false }
        return OnSiteRule.isOnSite(currentLocation, at: selected.pharmacy)
    }

    var canSend: Bool { selected != nil && !isOwnRequest && !isSending }

    // MARK: - Actions
    
    /// How far I am from the pharmacy I picked (nil if unknown).
    var distanceToSelected: Double? {
        guard let selected, let currentLocation else { return nil }
        return selected.pharmacy.distance(from: currentLocation)
    }

    /// Re-check my position (e.g. after arriving at the pharmacy).
    func refreshLocation() async {
        if let fresh = try? await locationService.currentLocation() {
            currentLocation = fresh
            if let match = options.first(where: { OnSiteRule.isOnSite(fresh, at: $0.pharmacy) }) {
                selected = match
            }
        }
    }

    func load() async {
        do {
            let pharmacies = try pharmacyService.loadPharmacies()

            // Use my location if allowed; otherwise list pharmacies near the request's area.
            if locationService.authorizationStatus == .authorizedWhenInUse
                || locationService.authorizationStatus == .authorizedAlways {
                currentLocation = try? await locationService.currentLocation()
            }
            let origin = currentLocation
                ?? CLLocation(latitude: request.areaLatitude, longitude: request.areaLongitude)

            options = Array(PharmacyFinder.nearby(pharmacies, from: origin).prefix(20))

            // Standing in one already? Pre-select it.
            if selected == nil, let currentLocation {
                selected = options.first { OnSiteRule.isOnSite(currentLocation, at: $0.pharmacy) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func send() async {
        guard canSend, let selected, let responderID = authService.currentUserID else { return }
        isSending = true
        errorMessage = nil
        defer { isSending = false }

        let now = Date()
        let response = AvailabilityResponse(
            id: UUID().uuidString,
            requestID: request.id,
            responderID: responderID,
            pharmacyID: selected.pharmacy.id,
            pharmacyName: selected.pharmacy.name,
            medicineKey: request.medicine.key,
            medicineName: request.medicine.displayName,
            source: .community,
            wasOnSite: isOnSite,
            createdAt: now,
            expiresAt: ExpiryPolicy.communityResponseExpiry(createdAt: now, onSiteConfirmations: 0),
            stillAvailableCount: 0,
            soldOutCount: 0,
            neverHereCount: 0
        )

        do {
            try await responseService.create(response)
            didSend = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
