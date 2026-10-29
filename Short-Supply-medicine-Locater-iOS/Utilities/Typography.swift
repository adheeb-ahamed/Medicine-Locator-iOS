//
//  Typography.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Rounded font (SF Pro Rounded) for headings and big numbers; body text stays SF Pro.
/// Built on text styles (.largeTitle, .headline…) so Dynamic Type still scales them.
extension Font {
    static let screenTitle  = Font.system(.largeTitle, design: .rounded, weight: .black) // ~34
    static let sectionTitle = Font.system(.title3,     design: .rounded, weight: .heavy) // ~20
    static let cardTitle    = Font.system(.headline,   design: .rounded, weight: .heavy) // ~17
    static let bigNumber    = Font.system(.title,      design: .rounded, weight: .black) // ~28
    static let buttonLabel  = Font.system(.headline,   design: .rounded, weight: .heavy)
}