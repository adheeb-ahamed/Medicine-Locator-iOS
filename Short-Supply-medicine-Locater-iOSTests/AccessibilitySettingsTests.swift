//
//  AccessibilitySettingsTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  AccessibilitySettingsTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct AccessibilitySettingsTests {

    // All 4 combinations: only "both off" keeps the animations.
    @Test(arguments: [(false, false, false),
                      (true,  false, true),
                      (false, true,  true),
                      (true,  true,  true)])
    func reduceMotionIfEitherIsOn(system: Bool, app: Bool, expected: Bool) {
        #expect(AccessibilitySettings.shouldReduceMotion(system: system, app: app) == expected)
    }
}