//
//  SourceViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation

/// Loads and ranks reports — either for a medicine (search) or for one request.
@MainActor
@Observable
final class SourcesViewModel {
    enum Scope: Equatable {
        case medicine(key: String)
        case request(id: String, medicineKey : String)
    }

    let scope: Scope
    private(set) var sources: [ScoredResponse] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private var pharmaciesByID: [String: Pharmacy] = [:]

    private let responseService: ResponseServicing
    private let pharmacyService: PharmacyServicing

    init(scope: Scope, responseService: ResponseServicing, pharmacyService: PharmacyServicing) {
        self.scope = scope
        self.responseService = responseService
        self.pharmacyService = pharmacyService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false; hasLoaded = true }

        do {
            let responses: [AvailabilityResponse]
            switch scope {
            case .medicine(let key):
                responses = try await responseService.responses(forMedicineKey: key)

            case .request(let id, let medicineKey):
                // Answers to this request + any verified pharmacy posts for the same medicine
                let answers = try await responseService.responses(forRequestID: id)
                let pharmacyPosts = try await responseService.responses(forMedicineKey: medicineKey)
                    .filter { $0.source == .verifiedPharmacy }
                    .filter { post in !answers.contains { $0.id == post.id } }
                responses = answers + pharmacyPosts
            }
            sources = SourceRanking.rank(responses)

            // Look-up table so each source can show its pharmacy's address/directions.
            pharmaciesByID = Dictionary(
                try pharmacyService.loadPharmacies().map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func pharmacy(for source: ScoredResponse) -> Pharmacy? {
        pharmaciesByID[source.response.pharmacyID]
    }
}
