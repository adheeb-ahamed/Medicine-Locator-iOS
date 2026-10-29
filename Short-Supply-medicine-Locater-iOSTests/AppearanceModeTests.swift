//
//  AppearanceModeTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  AppearanceModeTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import SwiftUI
@testable import Short_Supply_medicine_Locater_iOS

struct AppearanceModeTests {

    @Test func systemFollowsThePhone() {
        #expect(AppearanceMode.system.colorScheme == nil)     // nil = no override
        #expect(AppearanceMode.light.colorScheme == .light)
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }

    @Test func savedValueRoundTrips() {
        // @AppStorage saves the rawValue ("dark") and reads it back.
        for mode in AppearanceMode.allCases {
            #expect(AppearanceMode(rawValue: mode.rawValue) == mode)
        }
    }

    @Test func unknownSavedValueIsRejected() {
        #expect(AppearanceMode(rawValue: "purple") == nil)    // falls back to the .system default
    }
}
