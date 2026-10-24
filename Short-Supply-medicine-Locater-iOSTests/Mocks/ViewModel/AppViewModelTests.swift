//
//  AppViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct AppViewModelTests {

    /// Builds an AppViewModel with mocks and a throwaway UserDefaults.
    private func makeSUT(onboarded: Bool,
                         lockEnabled: Bool = false,
                         faceIDSucceeds: Bool = true) -> (AppViewModel, MockAuthService) {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        defaults.set(onboarded, forKey: "hasCompletedOnboarding")
        defaults.set(lockEnabled, forKey: "isAppLockEnabled")

        let auth = MockAuthService()
        let viewModel = AppViewModel(
            authService: auth,
            userService: MockUserService(),
            biometricService: MockBiometricService(result: faceIDSucceeds),
            defaults: defaults
        )
        return (viewModel, auth)
    }

    @Test func firstLaunchShowsOnboarding() async {
        let (vm, auth) = makeSUT(onboarded: false)
        await vm.start()
        #expect(vm.phase == .onboarding)
        #expect(auth.anonymousSignInCount == 0)
    }

    @Test func getStartedSignsInAnonymously() async {
        let (vm, auth) = makeSUT(onboarded: false)
        await vm.completeOnboarding()
        #expect(vm.phase == .ready)
        #expect(auth.anonymousSignInCount == 1)
        #expect(vm.profile?.role == .member)
        #expect(vm.isAnonymous)
    }

    @Test func returningUserWithLockStartsLocked() async {
        let (vm, _) = makeSUT(onboarded: true, lockEnabled: true)
        await vm.start()
        #expect(vm.phase == .locked)
    }

    @Test func failedFaceIDStaysLocked() async {
        let (vm, _) = makeSUT(onboarded: true, lockEnabled: true, faceIDSucceeds: false)
        await vm.start()
        let unlocked = await vm.unlock()
        #expect(!unlocked)
        #expect(vm.phase == .locked)
    }

    @Test func successfulFaceIDUnlocks() async {
        let (vm, _) = makeSUT(onboarded: true, lockEnabled: true)
        await vm.start()
        await vm.unlock()
        #expect(vm.phase == .ready)
    }

    @Test func backgroundingLocksOnlyWhenEnabled() async {
        let (locking, _) = makeSUT(onboarded: true, lockEnabled: true)
        await locking.start()
        await locking.unlock()
        locking.lock()
        #expect(locking.phase == .locked)

        let (notLocking, _) = makeSUT(onboarded: true, lockEnabled: false)
        await notLocking.start()
        notLocking.lock()
        #expect(notLocking.phase == .ready)
    }

    @Test func linkingEmailKeepsMemberRole() async throws {
        let (vm, auth) = makeSUT(onboarded: false)
        await vm.completeOnboarding()
        _ = try await auth.createAccount(email: "ad@example.com", password: "secret1")
        await vm.refreshProfile()
        #expect(vm.profile?.role == .member)
        #expect(!vm.isAnonymous)
        #expect(auth.anonymousSignInCount == 1)   // same account, not a new one
    }
    
    @Test func deletingAccountReturnsToWelcome() async {
        let (vm, _) = makeSUT(onboarded: true, lockEnabled: true)
        await vm.start()
        await vm.unlock()

        vm.resetAfterAccountDeletion()

        #expect(vm.phase == .onboarding)
        #expect(vm.profile == nil)
        #expect(!vm.isAppLockEnabled)
    }
}
