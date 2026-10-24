//
//  VerifyPharmacyViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation

/// "I run a pharmacy" application form.
@MainActor
@Observable
final class VerifyPharmacyViewModel {
    var selectedPharmacyID: String?
    var licenceNumber = ""
    var contactName = ""
    var phone = ""

    private(set) var pharmacies: [Pharmacy] = []
    private(set) var existing: VerificationRequest?
    private(set) var isSubmitting = false
    private(set) var errorMessage: String?

    let profile: UserProfile
    private let verificationService: VerificationServicing
    private let pharmacyService: PharmacyServicing

    init(profile: UserProfile,
         verificationService: VerificationServicing,
         pharmacyService: PharmacyServicing) {
        self.profile = profile
        self.verificationService = verificationService
        self.pharmacyService = pharmacyService
    }

    // MARK: - Rules for the form

    /// Pharmacies must have an email account (so we can contact them and they keep access).
    var canApply: Bool { !profile.isAnonymous }

    var phoneDigits: String { phone.filter(\.isNumber) }

    var isValid: Bool {
        selectedPharmacyID != nil
            && !licenceNumber.trimmingCharacters(in: .whitespaces).isEmpty
            && !contactName.trimmingCharacters(in: .whitespaces).isEmpty
            && phoneDigits.count >= 9
    }

    /// You can apply if you have no application yet, or the last one was rejected.
    var canSubmit: Bool {
        canApply && isValid && !isSubmitting && (existing == nil || existing?.status == .rejected)
    }

    // MARK: - Actions

    func load() async {
        do {
            pharmacies = try pharmacyService.loadPharmacies()
            existing = try await verificationService.application(for: profile.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submit() async {
        guard canSubmit,
              let pharmacyID = selectedPharmacyID,
              let pharmacy = pharmacies.first(where: { $0.id == pharmacyID }) else { return }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let application = VerificationRequest(
            id: profile.id,
            userID: profile.id,
            pharmacyID: pharmacy.id,
            pharmacyName: pharmacy.name,
            licenceNumber: licenceNumber.trimmingCharacters(in: .whitespaces),
            contactName: contactName.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces),
            status: .pending,
            createdAt: .now
        )

        do {
            try await verificationService.submit(application)
            existing = application
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
