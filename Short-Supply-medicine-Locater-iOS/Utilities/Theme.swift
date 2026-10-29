//
//  Theme.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

//
//  Theme.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Every colour and size in the redesign lives here.
/// Views never type a hex code — they ask Theme. Change it here, the whole app changes.
enum Theme {

    // MARK: - Brand
    static let accent     = Color(hex: 0x08716F)   // teal = trust (links, selected tab, info)
    static let accentTint = Color(hex: 0xDDF1EE)   // light teal behind teal icons
    static let coral      = Color(hex: 0xE5532F)   // coral = hopeful action (main button, scan, help)
    static let coralText  = Color(hex: 0xC7431F)   // darker coral for small text (passes AA)
    static let coralTint  = Color(hex: 0xFFE7DF)

    // MARK: - Surfaces
    static let background = Color(hex: 0xF7F5F2)  // warm off-white behind every screen
    static let card       = Color.white
    static let ringTrack  = Color(hex: 0xEDEBE7)   // empty part of the confidence ring

    // MARK: - Meaning (same hex as before, so old screens keep working)
    static let success     = Color(hex: 0x197A34)
    static let successTint = Color(hex: 0xE2F3E6)
    static let warning     = Color(hex: 0xA85200)
    static let warningTint = Color(hex: 0xFFF1DA)
    static let danger      = Color(hex: 0xC8102E)
    static let dangerTint  = Color(hex: 0xFCE8EA)
    static let tertiary    = Color(hex: 0x8A8A8E)

    // MARK: - Hero gradient (top of Home, sources, success screens)
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0x0E8C88), Color(hex: 0x054845)],
                       startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Shape
    enum Radius {
        static let card: CGFloat = 24   // white cards
        static let list: CGFloat = 22   // grouped lists
        static let tile: CGFloat = 14   // icon tiles
        static let chip: CGFloat = 12   // filter chips
        static let hero: CGFloat = 36   // bottom corners of the gradient header
    }

    static let buttonHeight: CGFloat = 56   // big bottom buttons (Apple minimum tap size is 44)
}
