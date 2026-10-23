//
//  NotificationPreference.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// What the user wants to be notified about. Saved in UserDefaults.
struct NotificationPreferences: Equatable {
    var answers = true      // new answers to my requests
    var arrivals = false    // "you're at a pharmacy" — opt-in, needs Always location
    var discreet = true     // hide medicine / pharmacy names on the lock screen

    private enum Keys {
        static let answers  = "notify.answers"
        static let arrivals = "notify.arrivals"
        static let discreet = "notify.discreet"
    }

    static func load(from defaults: UserDefaults) -> NotificationPreferences {
        var preferences = NotificationPreferences()
        // Only override the default if the user has actually set something.
        if defaults.object(forKey: Keys.answers) != nil  { preferences.answers  = defaults.bool(forKey: Keys.answers) }
        if defaults.object(forKey: Keys.arrivals) != nil { preferences.arrivals = defaults.bool(forKey: Keys.arrivals) }
        if defaults.object(forKey: Keys.discreet) != nil { preferences.discreet = defaults.bool(forKey: Keys.discreet) }
        return preferences
    }

    func save(to defaults: UserDefaults) {
        defaults.set(answers, forKey: Keys.answers)
        defaults.set(arrivals, forKey: Keys.arrivals)
        defaults.set(discreet, forKey: Keys.discreet)
    }
}
