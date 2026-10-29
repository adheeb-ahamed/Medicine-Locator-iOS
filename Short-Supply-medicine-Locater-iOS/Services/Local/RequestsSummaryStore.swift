//
//  RequestsSummaryStore.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation
import WidgetKit

/// Saves / loads the RequestsSummary as JSON.
/// Used by the app (writes), Siri (reads) and the widget (reads).
struct RequestsSummaryStore {
    static let key = "requestsSummary"
    /// Shared space between the app and the widget (App Groups capability).
    static let appGroupID = "group.com.ad.MedicineLocator"
    /// The widget's id — the widget uses this same constant.
    static let widgetKind = "MedicineLocatorWidget"

    let defaults: UserDefaults

    /// Real app: the shared App Group. Tests: their own UserDefaults.
    /// (?? .standard = fallback if the group isn't set up, so the app never crashes.)
    init(defaults: UserDefaults = UserDefaults(suiteName: RequestsSummaryStore.appGroupID) ?? .standard) {
        self.defaults = defaults
    }

    func save(_ summary: RequestsSummary) {
        let changed = !summary.hasSameContent(as: load())   // compare with what's saved now
        if let data = try? JSONEncoder().encode(summary) {
            defaults.set(data, forKey: Self.key)
        }
        // Only ask iOS to redraw the widget when the numbers really changed.
        if changed {
            WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)
        }
    }

    func load() -> RequestsSummary? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(RequestsSummary.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
        WidgetCenter.shared.reloadTimelines(ofKind: Self.widgetKind)   // widget goes back to empty
    }
}
