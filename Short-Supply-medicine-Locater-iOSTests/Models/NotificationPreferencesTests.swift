//
//  NotificationPreferencesTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

struct NotificationPreferencesTests {

    @Test func defaultsArePrivacyFirst() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let preferences = NotificationPreferences.load(from: defaults)
        #expect(preferences.answers)
        #expect(!preferences.arrivals)      // opt-in
        #expect(preferences.discreet)       // on by default
    }

    @Test func savedChoicesComeBack() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        var preferences = NotificationPreferences()
        preferences.discreet = false
        preferences.arrivals = true
        preferences.save(to: defaults)
        #expect(NotificationPreferences.load(from: defaults) == preferences)
    }
}
