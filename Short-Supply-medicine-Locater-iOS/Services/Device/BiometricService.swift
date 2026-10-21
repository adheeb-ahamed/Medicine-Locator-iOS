//
//  BiometricService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
import LocalAuthentication

/// Face ID / Touch ID, falling back to the device passcode.
@MainActor
final class BiometricService: BiometricServicing {
    /// .deviceOwnerAuthentication = biometrics OR passcode,
    /// so a user is never locked out of their own app.
    private let policy: LAPolicy = .deviceOwnerAuthentication

    var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(policy, error: &error)
    }

    func authenticate(reason: String) async -> Bool {
        let context = LAContext()      // a fresh context every time
        do {
            return try await context.evaluatePolicy(policy, localizedReason: reason)
        } catch {
            return false               // cancelled, failed, or not set up
        }
    }
}
