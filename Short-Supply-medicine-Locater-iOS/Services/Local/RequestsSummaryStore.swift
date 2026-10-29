//
//  RequestsSummaryStore.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  RequestsSummaryStore.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// Saves and loads the RequestsSummary as JSON in UserDefaults.
/// (Phase 14 will point this at a shared App Group so the widget can read it too.)
struct RequestsSummaryStore {
    static let key = "requestsSummary"
    let defaults: UserDefaults

    /// Tests pass their own UserDefaults so they never touch the real app data.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ summary: RequestsSummary) {
        // Codable → JSON bytes → UserDefaults
        if let data = try? JSONEncoder().encode(summary) {
            defaults.set(data, forKey: Self.key)
        }
    }

    func load() -> RequestsSummary? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }   // nothing saved yet
        return try? JSONDecoder().decode(RequestsSummary.self, from: data)
    }

    /// Used when the account is deleted.
    func clear() {
        defaults.removeObject(forKey: Self.key)
    }
}