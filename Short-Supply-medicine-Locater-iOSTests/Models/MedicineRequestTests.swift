//
//  MedicineRequestTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct MedicineRequestTests {

    @Test func openRequestPastExpiryIsExpired() {
        let request = TestData.request(expiresAt: .now - .hours(1))
        #expect(request.effectiveStatus() == .expired)
    }

    @Test func foundRequestStaysFoundAfterExpiry() {
        let request = TestData.request(status: .found, expiresAt: .now - .hours(1))
        #expect(request.effectiveStatus() == .found)
    }

    @Test func blurSnapsToGrid() {
        #expect(MedicineRequest.blur(6.9134) == 6.9)
    }
}
