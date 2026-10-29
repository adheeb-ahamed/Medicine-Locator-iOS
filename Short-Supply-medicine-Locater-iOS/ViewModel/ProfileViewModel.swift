//
//  ProfileViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation

/// Reputation total + where it came from.
@MainActor
@Observable
final class ProfileViewModel {
    private(set) var entries: [ReputationEntry] = []
    private(set) var errorMessage: String?

    private let reputationService: ReputationServicing
    private let authService: AuthServicing

    init(reputationService: ReputationServicing, authService: AuthServicing) {
        self.reputationService = reputationService
        self.authService = authService
    }

    var total: Int { ReputationPolicy.total(of: entries) }
    var level: HelperLevel { HelperLevel(reputation: total) }
    var levelProgress: Double { HelperLevel.progress(for: total) }
    var pointsToNextLevel: Int? { HelperLevel.pointsToNext(for: total) }

    /// Newest first, last 5.
    var recent: [ReputationEntry] {
        Array(entries.sorted { $0.createdAt > $1.createdAt }.prefix(5))
    }

    func load() async {
        guard let userID = authService.currentUserID else { return }
        do {
            entries = try await reputationService.entries(for: userID)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
