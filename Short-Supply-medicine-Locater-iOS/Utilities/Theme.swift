//
//  Theme.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  Theme.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Every colour and size in the redesign lives here.
/// Views never type a hex code — they ask Theme. Change it here, the whole app changes.
/// Dark values come from the "Dark Mode" page of the Figma redesign.
enum Theme {

    // MARK: - Brand (text & icons — lighter in dark mode so they stay readable)
    static let accent     = Color(light: 0x08716F, dark: 0x3FC1C3)   // teal = trust
    static let accentTint = Color(light: 0xDDF1EE, dark: 0x123B39)
    static let coral      = Color(hex: 0xE5532F)                     // main buttons — same in both
    static let coralText  = Color(light: 0xC7431F, dark: 0xFF8A66)
    static let coralTint  = Color(light: 0xFFE7DF, dark: 0x3A2018)

    // MARK: - Fills (backgrounds BEHIND WHITE TEXT — stay deep in both modes)
    static let accentFill  = Color(hex: 0x08716F)
    static let coralFill   = Color(hex: 0xC7431F)
    static let successFill = Color(hex: 0x197A34)
    static let warningFill = Color(hex: 0xA85200)
    static let dangerFill  = Color(hex: 0xC8102E)

    // MARK: - Surfaces
    static let background = Color(light: 0xF7F5F2, dark: 0x0F1413)   // behind every screen
    static let card       = Color(light: 0xFFFFFF, dark: 0x1C2321)   // cards, pills, sheets
    static let ringTrack  = Color(light: 0xEDEBE7, dark: 0x2C3533)   // empty part of rings

    // MARK: - Meaning
    static let success     = Color(light: 0x197A34, dark: 0x4CD37A)
    static let successTint = Color(light: 0xE2F3E6, dark: 0x15301E)
    static let warning     = Color(light: 0xA85200, dark: 0xFFB257)
    static let warningTint = Color(light: 0xFFF1DA, dark: 0x4A4126)
    static let danger      = Color(light: 0xC8102E, dark: 0xFF7B7B)
    static let dangerTint  = Color(light: 0xFCE8EA, dark: 0x3D1E21)
    static let tertiary    = Color(light: 0x8A8A8E, dark: 0x98989F)

    // MARK: - Hero gradient (a little darker at night so it doesn't glare)
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [Color(light: 0x0E8C88, dark: 0x0B6C69),
                                Color(light: 0x054845, dark: 0x043937)],
                       startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Shape
    enum Radius {
        static let card: CGFloat = 24   // cards
        static let list: CGFloat = 22   // grouped lists
        static let tile: CGFloat = 14   // icon tiles
        static let chip: CGFloat = 12   // filter chips
        static let hero: CGFloat = 36   // bottom corners of the gradient header
    }

    static let buttonHeight: CGFloat = 56   // big bottom buttons (Apple minimum tap size is 44)
}