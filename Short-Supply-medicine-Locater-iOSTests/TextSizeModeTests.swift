//
//  TextSizeModeTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  TextSizeModeTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import SwiftUI
@testable import Short_Supply_medicine_Locater_iOS

struct TextSizeModeTests {

    @Test func systemAllowsEverySize() {
        // Full range = we don't override; the iPhone setting decides.
        let range = TextSizeMode.system.range
        #expect(range.contains(.xSmall))
        #expect(range.contains(.accessibility5))
    }

    @Test func otherModesPinOneSize() {
        #expect(TextSizeMode.large.range == .xxLarge ... .xxLarge)
        #expect(TextSizeMode.largest.range == .accessibility5 ... .accessibility5)
    }

    @Test func biggerModesUseAccessibilitySizes() {
        // These are the sizes where AdaptiveStack switches cards to vertical.
        #expect(TextSizeMode.extraLarge.range.lowerBound.isAccessibilitySize)
        #expect(TextSizeMode.largest.range.lowerBound.isAccessibilitySize)
        #expect(!TextSizeMode.large.range.lowerBound.isAccessibilitySize)
    }

    @Test func savedValueRoundTrips() {
        for mode in TextSizeMode.allCases {
            #expect(TextSizeMode(rawValue: mode.rawValue) == mode)
        }
    }
}