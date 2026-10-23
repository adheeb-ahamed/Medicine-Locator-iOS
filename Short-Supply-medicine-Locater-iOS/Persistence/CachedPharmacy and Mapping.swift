//
//  CachedPharmacy and Mapping.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreData

extension CachedPharmacy {

    /// Copy a Pharmacy struct into this Core Data row.
    func update(from pharmacy: Pharmacy) {
        id = pharmacy.id
        name = pharmacy.name
        address = pharmacy.address
        district = pharmacy.district
        latitude = pharmacy.latitude
        longitude = pharmacy.longitude
        phone = pharmacy.phone
        kind = pharmacy.kind.rawValue
        isVerified = pharmacy.isVerified
        cachedAt = .now
    }

    /// Turn this Core Data row back into a Pharmacy struct (nil if data is broken).
    var pharmacy: Pharmacy? {
        guard let id, let name else { return nil }
        return Pharmacy(
            id: id,
            name: name,
            address: address ?? "",
            district: district ?? "",
            latitude: latitude,
            longitude: longitude,
            phone: phone,
            kind: Pharmacy.Kind(rawValue: kind ?? "") ?? .retail,
            isVerified: isVerified
        )
    }
}
