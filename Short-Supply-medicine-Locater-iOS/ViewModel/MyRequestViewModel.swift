//
//  MyRequestViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation

/// "My Requests" — the watchlist (MVP item 9).
@MainActor
@Observable
final class MyRequestsViewModel {
    private(set) var requests: [MedicineRequest] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let requestService: RequestServicing
    private let authService: AuthServicing

    init(requestService: RequestServicing, authService: AuthServicing) {
        self.requestService = requestService
        self.authService = authService
    }

    var active: [MedicineRequest] { requests.filter { $0.effectiveStatus() == .open } }
    var past: [MedicineRequest]   { requests.filter { $0.effectiveStatus() != .open } }

    func load() async {
        guard let ownerID = authService.currentUserID else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            requests = try await requestService.requests(ownedBy: ownerID)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markFound(_ request: MedicineRequest, response: AvailabilityResponse?) async {
        guard let ownerID = authService.currentUserID else { return }
        await perform {
            try await self.requestService.markFound(request.id, via: response, by: ownerID)
        }
    }

    func close(_ request: MedicineRequest) async {
        await perform { try await self.requestService.setStatus(.closed, foundResponseID: nil, for: request.id) }
    }

    func renew(_ request: MedicineRequest) async {
        await perform { try await self.requestService.renew(request.id, until: ExpiryPolicy.requestExpiry(from: .now)) }
    }

    /// Run a change, then reload so the list is up to date.
    private func perform(_ action: () async throws -> Void) async {
        do {
            try await action()
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
