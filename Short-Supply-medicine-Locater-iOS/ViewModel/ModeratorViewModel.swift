//
//  ModeratorViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation

/// The moderator's queue of pending applications.
@MainActor
@Observable
final class ModeratorViewModel {
    private(set) var queue: [VerificationRequest] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var pharmaciesByID: [String: Pharmacy] = [:]

    let moderatorID: String
    private let verificationService: VerificationServicing
    private let pharmacyService: PharmacyServicing

    init(moderatorID: String,
         verificationService: VerificationServicing,
         pharmacyService: PharmacyServicing) {
        self.moderatorID = moderatorID
        self.verificationService = verificationService
        self.pharmacyService = pharmacyService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            queue = try await verificationService.pendingApplications()
            pharmaciesByID = Dictionary(try pharmacyService.loadPharmacies().map { ($0.id, $0) },
                                        uniquingKeysWith: { first, _ in first })
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// The listed pharmacy — the moderator calls ITS public number, not the applicant's.
    func pharmacy(for application: VerificationRequest) -> Pharmacy? {
        pharmaciesByID[application.pharmacyID]
    }

    func approve(_ application: VerificationRequest, calledPublicNumber: Bool) async -> Bool {
        guard VerificationChecklist.canApprove(application, calledPublicNumber: calledPublicNumber) else {
            return false
        }
        return await perform { try await self.verificationService.approve(application, by: self.moderatorID) }
    }

    func reject(_ application: VerificationRequest, note: String) async -> Bool {
        await perform { try await self.verificationService.reject(application, by: self.moderatorID, note: note) }
    }

    private func perform(_ action: () async throws -> Void) async -> Bool {
        do {
            try await action()
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
