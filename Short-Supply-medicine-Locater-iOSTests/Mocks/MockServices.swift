//
//  MockServices.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
@testable import Short_Supply_medicine_Locater_iOS

/// Fake auth: no network, instant answers, and it records what was called.
@MainActor
final class MockAuthService: AuthServicing {
    var currentUserID: String?
    var currentEmail: String?
    private(set) var anonymousSignInCount = 0

    func signInAnonymously() async throws -> String {
        anonymousSignInCount += 1
        currentUserID = "anon-user"
        return "anon-user"
    }

    func signIn(email: String, password: String) async throws -> String {
        currentUserID = "email-user"
        currentEmail = email
        return "email-user"
    }

    func createAccount(email: String, password: String) async throws -> String {
        currentEmail = email                       // linking keeps the same uid
        return currentUserID ?? "email-user"
    }

    func sendPasswordReset(email: String) async throws {}

    func signOut() throws {
        currentUserID = nil
        currentEmail = nil
    }
}

/// Fake Firestore: returns a profile without touching the network.
@MainActor
final class MockUserService: UserServicing {
    func fetchOrCreateProfile(uid: String, email: String?) async throws -> UserProfile {
        UserProfile(id: uid, role: .member, reputation: 0, email: email, createdAt: .now)
    }
}

/// Fake Face ID: we decide whether it "succeeds".
@MainActor
final class MockBiometricService: BiometricServicing {
    var isAvailable = true
    var result: Bool

    init(result: Bool) { self.result = result }

    func authenticate(reason: String) async -> Bool { result }
}
