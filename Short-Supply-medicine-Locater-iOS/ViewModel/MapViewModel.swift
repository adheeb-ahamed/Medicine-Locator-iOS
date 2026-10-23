//
//  MapViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation

/// Map of all licensed pharmacies, with a text filter.
@MainActor
@Observable
final class MapViewModel {
    var filterText = ""
    private(set) var pharmacies: [Pharmacy] = []
    private(set) var errorMessage: String?

    private let pharmacyService: PharmacyServicing

    init(pharmacyService: PharmacyServicing) {
        self.pharmacyService = pharmacyService
    }

    /// Recalculated automatically whenever filterText or pharmacies change.
    var visiblePharmacies: [Pharmacy] {
        PharmacyFinder.matching(filterText, in: pharmacies)
    }

    func load() {
        do {
            pharmacies = try pharmacyService.loadPharmacies()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func pharmacy(withID id: String?) -> Pharmacy? {
        pharmacies.first { $0.id == id }
    }
}
