//
//  AccessibilitySettings.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  AccessibilitySettings.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// In-app accessibility settings (saved with @AppStorage).
enum AccessibilitySettings {
    /// UserDefaults key — one constant so Settings and the animated views can't disagree.
    static let reduceMotionKey = "reduceMotion"

    /// Animations are reduced if EITHER the iPhone setting OR the app setting is on.
    /// The app toggle can only ADD calm, never force animations back on.
    static func shouldReduceMotion(system: Bool, app: Bool) -> Bool {
        system || app
    }
}