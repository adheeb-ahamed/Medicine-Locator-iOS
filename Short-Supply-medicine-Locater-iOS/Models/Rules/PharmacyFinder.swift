//
//  PharmacyFinder.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreLocation

/// A pharmacy plus how far away it is.
struct NearbyPharmacy: Identifiable, Hashable {
    let pharmacy: Pharmacy
    let distance: CLLocationDistance     // metres

    var id: String { pharmacy.id }
}

/// Pure functions for finding and filtering pharmacies.
enum PharmacyFinder {

    /// Pharmacies within `radius` of a location, nearest first.
    static func nearby(_ pharmacies: [Pharmacy],
                       from location: CLLocation,
                       within radius: CLLocationDistance = Constants.Location.nearbyRadius) -> [NearbyPharmacy] {
        pharmacies
            .map { NearbyPharmacy(pharmacy: $0, distance: $0.distance(from: location)) }
            .filter { $0.distance <= radius }
            .sorted { $0.distance < $1.distance }
    }

    /// Pharmacies whose name, district or address contains the text (case-insensitive).
    static func matching(_ text: String, in pharmacies: [Pharmacy]) -> [Pharmacy] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return pharmacies }
        return pharmacies.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.district.localizedCaseInsensitiveContains(query) ||
            $0.address.localizedCaseInsensitiveContains(query)
        }
    }
}
