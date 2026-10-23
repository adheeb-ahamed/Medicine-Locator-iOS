//
//  OnSiteRule.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreLocation

/// Are you really at the pharmacy?
enum OnSiteRule {
    static func isOnSite(_ location: CLLocation,
                         at pharmacy: Pharmacy,
                         radius: CLLocationDistance = Constants.Location.onSiteRadius) -> Bool {
        // Negative accuracy = invalid fix. A fuzzy fix (e.g. ±500 m) can't prove you're inside 100 m.
        location.horizontalAccuracy >= 0
            && location.horizontalAccuracy <= radius
            && pharmacy.distance(from: location) <= radius
    }
}
