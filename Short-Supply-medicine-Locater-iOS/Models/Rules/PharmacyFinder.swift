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
    
    /// Every district in the list, A–Z, no duplicates.
    static func districts(in pharmacies: [Pharmacy]) -> [String] {
        Array(Set(pharmacies.map(\.district))).sorted()
    }

    /// The district of the closest pharmacy (used to pre-select the user's area).
    static func nearestDistrict(to location: CLLocation, in pharmacies: [Pharmacy]) -> String? {
        pharmacies.min { $0.distance(from: location) < $1.distance(from: location) }?.district
    }

    /// The average position of a district's pharmacies — a public point, not the user's location.
    static func centre(of district: String, in pharmacies: [Pharmacy]) -> CLLocationCoordinate2D? {
        let inDistrict = pharmacies.filter { $0.district == district }
        guard !inDistrict.isEmpty else { return nil }
        let count = Double(inDistrict.count)
        return CLLocationCoordinate2D(
            latitude: inDistrict.map(\.latitude).reduce(0, +) / count,
            longitude: inDistrict.map(\.longitude).reduce(0, +) / count
        )
    }
}
