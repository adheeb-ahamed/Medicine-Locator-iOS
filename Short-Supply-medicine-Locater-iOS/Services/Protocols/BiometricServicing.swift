//
//  BiometricServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation

/// Face ID / Touch ID / passcode check.
@MainActor
protocol BiometricServicing {
    var isAvailable: Bool { get }
    func authenticate(reason: String) async -> Bool
}
