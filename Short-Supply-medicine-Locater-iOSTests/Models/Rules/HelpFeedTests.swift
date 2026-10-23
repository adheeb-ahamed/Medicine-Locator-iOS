//
//  HelpFeedTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

struct HelpFeedTests {
    let me = CLLocation(latitude: 6.9, longitude: 79.85)

    @Test func showsOthersOpenNearbyRequestsOnly() {
        let mine     = TestData.request(id: "mine", ownerID: "me")
        let expired  = TestData.request(id: "expired", ownerID: "other", expiresAt: .now - .hours(1))
        let found    = TestData.request(id: "found", ownerID: "other", status: .found)
        var far      = TestData.request(id: "far", ownerID: "other")
        far.areaLatitude = 7.29                                 // Kandy-ish, ~45 km
        let good     = TestData.request(id: "good", ownerID: "other")

        let result = HelpFeed.nearby([mine, expired, found, far, good], from: me, excluding: "me")
        #expect(result.map(\.id) == ["good"])
    }
}
