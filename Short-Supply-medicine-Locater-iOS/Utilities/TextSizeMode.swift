//
//  TextSizeMode.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  TextSizeMode.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Optional in-app text size, saved in UserDefaults via @AppStorage.
/// "System" follows the iPhone's own Larger Text setting (the default).
enum TextSizeMode: String, CaseIterable, Identifiable {
    case system, large, extraLarge, largest

    /// UserDefaults key — one constant so the App and Settings can't disagree.
    static let storageKey = "textSizeMode"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:     "System"
        case .large:      "Large"
        case .extraLarge: "Extra large"
        case .largest:    "Largest"
        }
    }

    /// Which text sizes the app is allowed to use.
    /// System = the full range, so the iPhone setting decides.
    /// Others = one fixed size (start and end are the same).
    /// We use a range (not "nil = no override") so the modifier is always there —
    /// adding/removing a modifier at the root would rebuild the app and reset the tabs.
    var range: ClosedRange<DynamicTypeSize> {
        switch self {
        case .system:     .xSmall ... .accessibility5
        case .large:      .xxLarge ... .xxLarge
        case .extraLarge: .accessibility2 ... .accessibility2
        case .largest:    .accessibility5 ... .accessibility5
        }
    }
}