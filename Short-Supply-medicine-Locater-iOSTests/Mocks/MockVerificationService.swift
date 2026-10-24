//
//  MockVerificationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockVerificationService: VerificationServicing {
    var stored: [String: VerificationRequest] = [:]

    func submit(_ application: VerificationRequest) async throws {
        stored[application.id] = application
    }

    func application(for userID: String) async throws -> VerificationRequest? {
        stored[userID]
    }

    func pendingApplications() async throws -> [VerificationRequest] {
        stored.values.filter { $0.status == .pending }.sorted { $0.createdAt < $1.createdAt }
    }

    func approve(_ application: VerificationRequest, by reviewerID: String) async throws {
        stored[application.id]?.status = .approved
        stored[application.id]?.reviewerID = reviewerID
    }

    func reject(_ application: VerificationRequest, by reviewerID: String, note: String) async throws {
        stored[application.id]?.status = .rejected
        stored[application.id]?.reviewerID = reviewerID
        stored[application.id]?.note = note
    }
}
