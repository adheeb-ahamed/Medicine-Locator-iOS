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
    
    private(set) var cached: [SourceSnapshot] = []      // shown when offline
    private(set) var isOffline = false

    private let connectivity: ConnectivityServicing?
    private let cache: SourceCacheServicing?

    init(scope: Scope,
             responseService: ResponseServicing,
             pharmacyService: PharmacyServicing,
             connectivity: ConnectivityServicing? = nil,       // nil in older tests → online, no cache
             cache: SourceCacheServicing? = nil) {
            self.scope = scope
            self.responseService = responseService
            self.pharmacyService = pharmacyService
            self.connectivity = connectivity
            self.cache = cache
    }
    
    var scopeKey: String {
            switch scope {
            case .medicine(let key):    "medicine:\(key)"
            case .request(let id, _):   "request:\(id)"
            }
    }
    

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false; hasLoaded = true }

        // Offline → show what we saved last time (only reports that haven't expired).
        if let connectivity, !connectivity.isOnline {
            isOffline = true
            sources = []
            cached = savedSnapshots()
            return
        }
        isOffline = false

        do {
            let responses: [AvailabilityResponse]
            switch scope {
            case .medicine(let key):
                responses = try await responseService.responses(forMedicineKey: key)
            case .request(let id, let medicineKey):
                let answers = try await responseService.responses(forRequestID: id)
                let pharmacyPosts = try await responseService.responses(forMedicineKey: medicineKey)
                    .filter { $0.source == .verifiedPharmacy }
                    .filter { post in !answers.contains { $0.id == post.id } }
                responses = answers + pharmacyPosts
            }

            sources = SourceRanking.rank(responses)
            cached = []
            cache?.save(sources, for: scopeKey)                // keep a copy for offline

            pharmaciesByID = Dictionary(
                try pharmacyService.loadPharmacies().map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
        } catch {
            errorMessage = error.localizedDescription
            cached = savedSnapshots()                          // network failed → fall back
        }
    }

    private func savedSnapshots() -> [SourceSnapshot] {
        (cache?.load(for: scopeKey) ?? []).filter { $0.expiresAt > .now }
    }

    func pharmacy(for source: ScoredResponse) -> Pharmacy? {
        pharmaciesByID[source.response.pharmacyID]
    }
}
