//
//  FirebaseAuthService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
import FirebaseAuth

/// Real authentication using Firebase Auth.
@MainActor
final class FirebaseAuthService: AuthServicing {
    private var auth: Auth { Auth.auth() }

    var currentUserID: String? { auth.currentUser?.uid }
    var currentEmail: String? { auth.currentUser?.email }

    func signInAnonymously() async throws -> String {
        let result = try await auth.signInAnonymously()
        return result.user.uid
    }

    func signIn(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func createAccount(email: String, password: String) async throws -> String {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Anonymous user? LINK the email so the uid stays the same
        // (they keep their requests and reputation).
        if let user = auth.currentUser, user.isAnonymous {
            let result = try await user.link(with: credential)
            try await result.user.sendEmailVerification()
            return result.user.uid
        }

        let result = try await auth.createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        return result.user.uid
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try auth.signOut()
    }
}
