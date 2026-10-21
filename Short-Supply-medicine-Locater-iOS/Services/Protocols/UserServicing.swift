//
//  UserServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation

/// Loads and saves the user's profile document.
@MainActor
protocol UserServicing {
    func fetchOrCreateProfile(uid: String, email: String?) async throws -> UserProfile
}
