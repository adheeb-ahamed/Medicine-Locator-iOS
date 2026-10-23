//
//  SearchHistoryServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Stores the user's recent medicine searches on the device.
@MainActor
protocol SearchHistoryServicing {
    func recentSearches() -> [String]
    func record(_ query: String)
    func delete(_ query: String)
    func clearAll()
}
