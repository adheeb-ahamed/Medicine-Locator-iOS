//
//  AccountViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Foundation
import Observation

/// Deleting an account: server profile, sign-in, and everything on this iPhone.
@MainActor
@Observable
final class AccountViewModel {
    private(set) var isWorking = false
    private(set) var errorMessage: String?

    private let authService: AuthServicing
    private let userService: UserServicing
    private let searchHistory: SearchHistoryServicing
    private let sourceCache: SourceCacheServicing

    init(authService: AuthServicing,
         userService: UserServicing,
         searchHistory: SearchHistoryServicing,
         sourceCache: SourceCacheServicing) {
        self.authService = authService
        self.userService = userService
        self.searchHistory = searchHistory
        self.sourceCache = sourceCache
    }

    /// Returns true if everything was deleted.
    func deleteAccount() async -> Bool {
        guard let userID = authService.currentUserID else { return false }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            try await userService.deleteProfile(uid: userID)   // 1. Firestore profile
            try await authService.deleteAccount()              // 2. Firebase sign-in
            searchHistory.clearAll()                           // 3. Local data
            sourceCache.clearAll()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}