//
//  SettingsViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation

/// Settings: clear on-device data, simulate offline (debug).
@MainActor
@Observable
final class SettingsViewModel {
    private(set) var infoMessage: String?

    private let searchHistory: SearchHistoryServicing
    private let sourceCache: SourceCacheServicing
    private let connectivity: ConnectivityServicing

    init(searchHistory: SearchHistoryServicing,
         sourceCache: SourceCacheServicing,
         connectivity: ConnectivityServicing) {
        self.searchHistory = searchHistory
        self.sourceCache = sourceCache
        self.connectivity = connectivity
    }

    /// A pass-through to the shared connectivity service, so a Toggle can bind to it.
    var simulateOffline: Bool {
        get { connectivity.simulateOffline }
        set { connectivity.simulateOffline = newValue }
    }

    func clearSearchHistory() {
        searchHistory.clearAll()
        infoMessage = "Search history cleared."
    }

    func clearSavedReports() {
        sourceCache.clearAll()
        infoMessage = "Saved reports cleared."
    }
}
