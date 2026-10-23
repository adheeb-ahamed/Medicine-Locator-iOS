//
//  NewRequestViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation
import CoreLocation

/// The "New request" form.
@MainActor
@Observable
final class NewRequestViewModel {
    var medicineName: String
    var strength = ""
    var selectedDistrict: String?

    private(set) var districts: [String] = []
    private(set) var isPosting = false
    private(set) var errorMessage: String?
    private(set) var postedRequest: MedicineRequest?

    private var pharmacies: [Pharmacy] = []
    private let requestService: RequestServicing
    private let pharmacyService: PharmacyServicing
    private let locationService: LocationServicing
    private let authService: AuthServicing

    init(medicineName: String = "",
         requestService: RequestServicing,
         pharmacyService: PharmacyServicing,
         locationService: LocationServicing,
         authService: AuthServicing) {
        self.medicineName = medicineName
        self.requestService = requestService
        self.pharmacyService = pharmacyService
        self.locationService = locationService
        self.authService = authService
    }

    // MARK: - Validation

    var trimmedName: String { medicineName.trimmingCharacters(in: .whitespacesAndNewlines) }
    var isControlled: Bool { MedicinePolicy.isControlled(medicineName) }

    var canPost: Bool {
        !trimmedName.isEmpty && !isControlled && selectedDistrict != nil && !isPosting
    }

    // MARK: - Actions

    func load() async {
        do {
            pharmacies = try pharmacyService.loadPharmacies()
            districts = PharmacyFinder.districts(in: pharmacies)

            // Pre-select the user's district ONLY if location is already allowed.
            // (We never pop up a permission request on this form.)
            let status = locationService.authorizationStatus
            if selectedDistrict == nil,
               status == .authorizedWhenInUse || status == .authorizedAlways,
               let location = try? await locationService.currentLocation() {
                selectedDistrict = PharmacyFinder.nearestDistrict(to: location, in: pharmacies)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func post() async {
        guard canPost,
              let district = selectedDistrict,
              let centre = PharmacyFinder.centre(of: district, in: pharmacies) else { return }
        guard let ownerID = authService.currentUserID else {
            errorMessage = "You're not signed in. Please restart the app."
            return
        }

        isPosting = true
        errorMessage = nil
        defer { isPosting = false }

        let now = Date()
        let request = MedicineRequest(
            id: UUID().uuidString,
            ownerID: ownerID,
            medicine: Medicine(name: trimmedName,
                               strength: strength.trimmingCharacters(in: .whitespacesAndNewlines),
                               isControlled: false),
            areaName: district,
            areaLatitude: MedicineRequest.blur(centre.latitude),     // district centre, blurred again
            areaLongitude: MedicineRequest.blur(centre.longitude),
            status: .open,
            createdAt: now,
            expiresAt: ExpiryPolicy.requestExpiry(from: now),        // Phase 3 rule: 7 days
            responseCount: 0
        )

        do {
            try await requestService.create(request)
            postedRequest = request          // the View switches to "Request posted"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
