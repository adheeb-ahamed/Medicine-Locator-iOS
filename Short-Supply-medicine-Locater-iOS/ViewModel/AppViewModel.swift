//
//  AppViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
import Observation

/// App-wide state: which "phase" the app is in, and who is signed in.
/// RootView reads `phase` and shows the matching screen.
@MainActor
@Observable
final class AppViewModel {
    enum Phase: Equatable {
        case loading
        case onboarding
        case locked
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .loading
    private(set) var profile: UserProfile?

    /// Saved in UserDefaults so it survives app restarts.
    var isAppLockEnabled: Bool {
        didSet { defaults.set(isAppLockEnabled, forKey: Keys.appLock) }
    }

    let authService: AuthServicing
    private let userService: UserServicing
    private let biometricService: BiometricServicing
    private let defaults: UserDefaults

    private enum Keys {
        static let onboarding = "hasCompletedOnboarding"
        static let appLock    = "isAppLockEnabled"
    }

    /// Services are passed IN (dependency injection), so tests can pass mocks.
    init(authService: AuthServicing,
         userService: UserServicing,
         biometricService: BiometricServicing,
         defaults: UserDefaults = .standard) {
        self.authService = authService
        self.userService = userService
        self.biometricService = biometricService
        self.defaults = defaults
        self.isAppLockEnabled = defaults.bool(forKey: Keys.appLock)
    }

    // MARK: - Derived values

    var isAnonymous: Bool { profile?.isAnonymous ?? true }
    var isBiometricAvailable: Bool { biometricService.isAvailable }

    /// Only lock if the user turned it on AND the device can unlock.
    private var shouldLock: Bool { isAppLockEnabled && biometricService.isAvailable }

    // MARK: - Lifecycle

    func start() async {
        guard defaults.bool(forKey: Keys.onboarding) else {
            phase = .onboarding
            return
        }
        await loadSession(lockAfterLoading: shouldLock)
    }

    func completeOnboarding() async {
        defaults.set(true, forKey: Keys.onboarding)
        phase = .loading
        await loadSession(lockAfterLoading: false)
    }

    // MARK: - App lock

    @discardableResult
    func unlock() async -> Bool {
        guard phase == .locked else { return true }
        let success = await biometricService.authenticate(reason: "Unlock Medicine Locator")
        if success { phase = .ready }
        return success
    }

    /// Called when the app goes to the background.
    func lock() {
        if shouldLock && phase == .ready {
            phase = .locked
        }
    }

    // MARK: - Account

    /// Call after signing in or creating an account.
    func refreshProfile() async {
        await loadSession(lockAfterLoading: false)
    }

    func signOut() async throws {
        try authService.signOut()
        profile = nil
        phase = .loading
        await loadSession(lockAfterLoading: false)   // gives a fresh anonymous account
    }
    
    /// After deleting an account, start again from the welcome screen.
    func resetAfterAccountDeletion() {
        defaults.removeObject(forKey: Keys.onboarding)
        isAppLockEnabled = false
        profile = nil
        phase = .onboarding
    }

    // MARK: - Private

    private func loadSession(lockAfterLoading: Bool) async {
        do {
            let uid: String
            if let existing = authService.currentUserID {
                uid = existing
            } else {
                uid = try await authService.signInAnonymously()
            }
            profile = try await userService.fetchOrCreateProfile(
                uid: uid,
                email: authService.currentEmail
            )
            phase = lockAfterLoading ? .locked : .ready
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
