//
//  Appearance.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  AppearanceMode.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// The user's Light / Dark choice in Settings. Saved in UserDefaults via @AppStorage.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    /// UserDefaults key — one constant so the App and Settings can't disagree.
    static let storageKey = "appearanceMode"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    /// nil = don't override → follow the iPhone's own setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}
