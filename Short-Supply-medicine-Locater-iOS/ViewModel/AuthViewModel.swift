//
//  AuthViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
import Observation

/// State + validation for the Sign in / Create account / Forgot password screens.
@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""

    private(set) var isWorking = false
    private(set) var errorMessage: String?
    private(set) var infoMessage: String?

    private let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
    }

    // MARK: - Validation

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var isValidEmail: Bool {
        let parts = trimmedEmail.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".")
    }

    /// Firebase requires at least 6 characters.
    var isValidPassword: Bool { password.count >= 6 }

    var passwordsMatch: Bool { password == confirmPassword }

    var canSignIn: Bool { isValidEmail && isValidPassword && !isWorking }
    var canCreateAccount: Bool { canSignIn && passwordsMatch }

    // MARK: - Actions

    func signIn() async -> Bool {
        await perform {
            _ = try await self.authService.signIn(email: self.trimmedEmail, password: self.password)
        }
    }

    func createAccount() async -> Bool {
        await perform {
            _ = try await self.authService.createAccount(email: self.trimmedEmail, password: self.password)
            self.infoMessage = "Account created. Check your inbox to verify your email."
        }
    }

    func resetPassword() async {
        _ = await perform {
            try await self.authService.sendPasswordReset(email: self.trimmedEmail)
            self.infoMessage = "If an account exists for this email, a reset link has been sent."
        }
    }

    /// Runs an action with a spinner and error handling in ONE place.
    private func perform(_ action: () async throws -> Void) async -> Bool {
        isWorking = true
        errorMessage = nil
        infoMessage = nil
        defer { isWorking = false }

        do {
            try await action()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
