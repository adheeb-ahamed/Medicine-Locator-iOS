//
//  HelpFeed.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreLocation

/// A request plus how far its district centre is from me.
struct NearbyRequest: Identifiable {
    let request: MedicineRequest
    let distance: CLLocationDistance
    var id: String { request.id }
}

enum HelpFeed {
    /// Other people's open requests near me, nearest first.
    static func nearby(_ requests: [MedicineRequest],
                       from location: CLLocation,
                       excluding userID: String,
                       within radius: CLLocationDistance = Constants.Location.helpRadius,
                       at now: Date = .now) -> [NearbyRequest] {
        requests
            .filter { $0.ownerID != userID && $0.effectiveStatus(at: now) == .open }
            .map { request in
                let area = CLLocation(latitude: request.areaLatitude, longitude: request.areaLongitude)
                return NearbyRequest(request: request, distance: area.distance(from: location))
            }
            .filter { $0.distance <= radius }
            .sorted { $0.distance < $1.distance }
    }
}
