//
//  IntentRouter.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  IntentRouter.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation
import Observation

/// Where Siri / Shortcuts want the app to go.
/// iOS creates the intents itself, so we can't pass services into them like our ViewModels.
/// This one shared object is the bridge: the intent writes here, the screens react.
@Observable
final class IntentRouter {
    static let shared = IntentRouter()

    var pendingSection: AppSection?   // switch to this tab / sidebar item
    var pendingSearch: String?        // then run this search on Home

    func openSearch(for medicine: String) {
        let name = medicine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }    // ignore an empty answer
        pendingSection = .home
        pendingSearch = name
    }

    func open(_ section: AppSection) {
        pendingSection = section
    }
}