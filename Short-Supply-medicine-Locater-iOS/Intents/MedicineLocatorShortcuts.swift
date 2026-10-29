//
//  MedicineLocatorShortcuts.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  MedicineLocatorShortcuts.swift
//  Short-Supply-medicine-Locater-iOS
//

import AppIntents

/// Registers the phrases with Siri, Spotlight and the Shortcuts app automatically —
/// the user doesn't have to set anything up.
/// Every phrase MUST contain \(.applicationName) (Apple's rule), which is "Medicine Locator".
struct MedicineLocatorShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: FindMedicineIntent(),
                    phrases: ["Find a medicine in \(.applicationName)",
                              "Search \(.applicationName)"],
                    shortTitle: "Find Medicine",
                    systemImageName: "magnifyingglass")

        AppShortcut(intent: CheckMyRequestsIntent(),
                    phrases: ["Check my requests in \(.applicationName)",
                              "Any answers in \(.applicationName)"],
                    shortTitle: "Check Requests",
                    systemImageName: "tray.full")

        AppShortcut(intent: OpenMyRequestsIntent(),
                    phrases: ["Open my requests in \(.applicationName)"],
                    shortTitle: "My Requests",
                    systemImageName: "list.bullet")
    }
}