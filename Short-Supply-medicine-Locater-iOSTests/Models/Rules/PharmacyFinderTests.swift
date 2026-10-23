//
//  PharmacyFinderTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

struct PharmacyFinderTests {
    let origin = CLLocation(latitude: 6.9344, longitude: 79.8428)

    // ~1.1 km, ~5.5 km and ~22 km north of the origin
    let near   = TestData.pharmacy(id: "near",   name: "Near",   latitude: 6.9444)
    let middle = TestData.pharmacy(id: "middle", name: "Middle", latitude: 6.9844)
    let far    = TestData.pharmacy(id: "far",    name: "Far",    district: "Gampaha", latitude: 7.1344)

    @Test func nearbySortsClosestFirstAndDropsFarOnes() {
        let result = PharmacyFinder.nearby([far, middle, near], from: origin)
        #expect(result.map(\.id) == ["near", "middle"])
    }

    @Test func nearbyIncludesDistance() {
        let result = PharmacyFinder.nearby([near], from: origin)
        #expect(result.first!.distance > 1_000 && result.first!.distance < 1_200)
    }

    @Test func emptySearchReturnsEverything() {
        #expect(PharmacyFinder.matching("  ", in: [near, far]).count == 2)
    }

    @Test func searchMatchesNameOrDistrictIgnoringCase() {
        #expect(PharmacyFinder.matching("NEAR", in: [near, far]).map(\.id) == ["near"])
        #expect(PharmacyFinder.matching("gampaha", in: [near, far]).map(\.id) == ["far"])
    }
}
