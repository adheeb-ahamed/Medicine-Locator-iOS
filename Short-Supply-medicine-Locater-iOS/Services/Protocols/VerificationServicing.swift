//
//  VerificationServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

@MainActor
protocol VerificationServicing {
    func submit(_ application: VerificationRequest) async throws
    func application(for userID: String) async throws -> VerificationRequest?
    func pendingApplications() async throws -> [VerificationRequest]
    func approve(_ application: VerificationRequest, by reviewerID: String) async throws
    func reject(_ application: VerificationRequest, by reviewerID: String, note: String) async throws
}
