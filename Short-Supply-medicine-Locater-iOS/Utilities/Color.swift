//
//  Color.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  Color.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Hex colours + colours that adapt to light / dark mode.

import SwiftUI
import UIKit

extension UIColor {
    /// UIColor(hex: 0x08716F)
    convenience init(hex: UInt32) {
        self.init(red:   CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8)  & 0xFF) / 255,
                  blue:  CGFloat(hex & 0xFF)         / 255,
                  alpha: 1)
    }

    /// A colour that picks `light` or `dark` by itself whenever the appearance changes.
    /// iOS calls the closure again on every switch, so no screen needs to refresh manually.
    static func adaptive(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        }
    }
}

extension Color {
    /// Color(hex: 0x08716F) — same in light and dark.
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// Color(light: 0xF7F5F2, dark: 0x0F1413) — switches automatically.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: .adaptive(light: light, dark: dark))
    }
}
