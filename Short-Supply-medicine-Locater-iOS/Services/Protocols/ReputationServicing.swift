//
//  ReputationServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

@MainActor
protocol ReputationServicing {
    func entries(for userID: String) async throws -> [ReputationEntry]
}
