//
//  AuthServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation

/// Everything the app needs from an authentication system.
/// FirebaseAuthService does it for real; MockAuthService fakes it in tests.
@MainActor
protocol AuthServicing {
    var currentUserID: String? { get }
    var currentEmail: String? { get }

    func signInAnonymously() async throws -> String
    func signIn(email: String, password: String) async throws -> String
    /// Links an email to the current anonymous account (keeps the same uid).
    func createAccount(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func signOut() throws
}
