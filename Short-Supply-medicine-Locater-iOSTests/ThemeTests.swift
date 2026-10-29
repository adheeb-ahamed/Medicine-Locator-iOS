//
//  ThemeTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import UIKit
@testable import Short_Supply_medicine_Locater_iOS

struct ThemeTests {

    @Test func adaptiveColourSwitchesWithAppearance() {
        let colour = UIColor.adaptive(light: 0xF7F5F2, dark: 0x0F1413)

        let light = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark  = colour.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))

        #expect(light == UIColor(hex: 0xF7F5F2))
        #expect(dark  == UIColor(hex: 0x0F1413))
    }

    @Test func hexIsReadCorrectly() {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(hex: 0x08716F).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #expect(Int((red * 255).rounded()) == 0x08)
        #expect(Int((green * 255).rounded()) == 0x71)
        #expect(Int((blue * 255).rounded()) == 0x6F)
    }
}