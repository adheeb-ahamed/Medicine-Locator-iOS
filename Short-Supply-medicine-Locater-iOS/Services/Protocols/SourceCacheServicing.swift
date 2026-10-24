//
//  SourceCacheServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Saves the last ranked results per screen, for offline use.
@MainActor
protocol SourceCacheServicing {
    func save(_ sources: [ScoredResponse], for scopeKey: String)
    func load(for scopeKey: String) -> [SourceSnapshot]
    func clearAll()
}
