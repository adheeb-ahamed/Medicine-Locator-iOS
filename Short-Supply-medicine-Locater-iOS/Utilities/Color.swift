//
//  Color.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//
//This is an extensioin that supports and adds hex colors

import SwiftUI

extension Color {
    /// To get Color(hex: 0x08716F), using the hex codes from Figma.
    init(hex: UInt32) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double(hex & 0xFF)         / 255
        )
    }
}
