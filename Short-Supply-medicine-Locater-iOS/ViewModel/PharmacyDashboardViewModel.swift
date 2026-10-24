//
//  PharmacyDashboardViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation

/// A verified pharmacy posts its own stock.
@MainActor
@Observable
final class PharmacyDashboardViewModel {
    var medicineName = ""
    var strength = ""
    var duration: PharmacyPostDuration = .twelveHours

    private(set) var pharmacy: Pharmacy?
    private(set) var posts: [AvailabilityResponse] = []
    private(set) var isPosting = false
    private(set) var errorMessage: String?
    private(set) var infoMessage: String?

    let profile: UserProfile
    private let responseService: ResponseServicing
    private let pharmacyService: PharmacyServicing

    init(profile: UserProfile,
         responseService: ResponseServicing,
         pharmacyService: PharmacyServicing) {
        self.profile = profile
        self.responseService = responseService
        self.pharmacyService = pharmacyService
    }

    // MARK: - Derived

    var trimmedName: String { medicineName.trimmingCharacters(in: .whitespacesAndNewlines) }
    var isControlled: Bool { MedicinePolicy.isControlled(medicineName) }

    var canPost: Bool {
        profile.role == .pharmacy && pharmacy != nil && !trimmedName.isEmpty && !isControlled && !isPosting
    }

    /// Only posts that are still live, newest first.
    var livePosts: [AvailabilityResponse] {
        posts.filter { $0.isLive() }.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Actions

    func load() async {
        do {
            pharmacy = try pharmacyService.loadPharmacies().first { $0.id == profile.pharmacyID }
            posts = try await responseService.posts(by: profile.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func post() async {
        guard canPost, let pharmacy else { return }
        isPosting = true
        errorMessage = nil
        infoMessage = nil
        defer { isPosting = false }

        let now = Date()
        let medicine = Medicine(name: trimmedName,
                                strength: strength.trimmingCharacters(in: .whitespacesAndNewlines),
                                isControlled: false)
        let post = AvailabilityResponse(
            id: UUID().uuidString,
            requestID: nil,                       // not tied to any request
            responderID: profile.id,
            pharmacyID: pharmacy.id,              // always THEIR pharmacy
            pharmacyName: pharmacy.name,
            medicineKey: medicine.key,
            medicineName: medicine.displayName,
            source: .verifiedPharmacy,
            wasOnSite: true,
            createdAt: now,
            expiresAt: ExpiryPolicy.pharmacyPostExpiry(createdAt: now, duration: duration),
            stillAvailableCount: 0,
            soldOutCount: 0,
            neverHereCount: 0
        )

        do {
            try await responseService.create(post)
            medicineName = ""
            strength = ""
            infoMessage = "Posted for \(duration.label)."
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markSoldOut(_ post: AvailabilityResponse) async {
        do {
            try await responseService.closePost(post.id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
