//
//  MockOfflineServices.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockConnectivityService: ConnectivityServicing {
    var isNetworkAvailable = true
    var simulateOffline = false
    var isOnline: Bool { isNetworkAvailable && !simulateOffline }
}

@MainActor
final class MockSourceCache: SourceCacheServicing {
    var saved: [String: [SourceSnapshot]] = [:]

    func save(_ sources: [ScoredResponse], for scopeKey: String) {
        saved[scopeKey] = sources.map { SourceSnapshot(scored: $0) }
    }

    func load(for scopeKey: String) -> [SourceSnapshot] {
        saved[scopeKey] ?? []
    }

    func clearAll() {
        saved = [:]
    }
}

@MainActor
final class MockReputationService: ReputationServicing {
    var entries: [ReputationEntry] = []
    func entries(for userID: String) async throws -> [ReputationEntry] {
        entries.filter { $0.userID == userID }
    }
}
