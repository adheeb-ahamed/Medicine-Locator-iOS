//
//  NotificationTextTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct NotificationTextTests {

    @Test func discreetHidesNames() {
        let text = NotificationText.newAnswer(medicineName: "Imatinib", pharmacyName: "City Pharmacy", discreet: true)
        #expect(!text.title.contains("Imatinib"))
        #expect(!text.body.contains("Imatinib"))
        #expect(!text.body.contains("City Pharmacy"))
    }

    @Test func normalModeShowsNames() {
        let text = NotificationText.newAnswer(medicineName: "Imatinib", pharmacyName: "City Pharmacy", discreet: false)
        #expect(text.title.contains("Imatinib"))
        #expect(text.body.contains("City Pharmacy"))
    }

    @Test func discreetArrivalHidesPharmacy() {
        let text = NotificationText.arrival(pharmacyName: "City Pharmacy", discreet: true)
        #expect(!text.title.contains("City Pharmacy"))
    }
}
