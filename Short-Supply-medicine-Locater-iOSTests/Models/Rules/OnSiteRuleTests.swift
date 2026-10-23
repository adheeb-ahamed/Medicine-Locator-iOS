//
//  OnSiteRuleTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

struct OnSiteRuleTests {
    let pharmacy = TestData.pharmacy(latitude: 6.9344, longitude: 79.8428)

    private func location(latitude: Double, accuracy: Double) -> CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: 79.8428),
                   altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 10,
                   timestamp: .now)
    }

    @Test func insideHundredMetresIsOnSite() {
        // 0.0005° latitude ≈ 55 m
        #expect(OnSiteRule.isOnSite(location(latitude: 6.9349, accuracy: 20), at: pharmacy))
    }

    @Test func overHundredMetresIsNotOnSite() {
        // 0.0015° ≈ 165 m
        #expect(!OnSiteRule.isOnSite(location(latitude: 6.9359, accuracy: 20), at: pharmacy))
    }

    @Test func fuzzyGPSCannotProveOnSite() {
        #expect(!OnSiteRule.isOnSite(location(latitude: 6.9344, accuracy: 500), at: pharmacy))
    }

    @Test func invalidGPSIsRejected() {
        #expect(!OnSiteRule.isOnSite(location(latitude: 6.9344, accuracy: -1), at: pharmacy))
    }
}
