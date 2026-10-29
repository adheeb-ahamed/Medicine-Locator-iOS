//
//  MyRequestViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation
import UserNotifications

/// "My Requests" — the watchlist (MVP item 9).
@MainActor
@Observable
final class MyRequestsViewModel {
    private(set) var requests: [MedicineRequest] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var showNotificationNudge = false

    private let requestService: RequestServicing
    private let authService: AuthServicing
    private let notificationService: NotificationServicing?
    private let summaryStore: RequestsSummaryStore   // Siri + widget summary

    init(requestService: RequestServicing,
         authService: AuthServicing,
         notificationService: NotificationServicing? = nil,
         summaryStore: RequestsSummaryStore = RequestsSummaryStore()) {
        self.requestService = requestService
        self.authService = authService
        self.notificationService = notificationService
        self.summaryStore = summaryStore
    }

    var active: [MedicineRequest] { requests.filter { $0.effectiveStatus() == .open } }
    var past: [MedicineRequest]   { requests.filter { $0.effectiveStatus() != .open } }
        /// Total answers on requests I'm still looking for (summary tile).
    var activeAnswerCount: Int { active.reduce(0) { $0 + $1.responseCount } }

    func load() async {
        guard let ownerID = authService.currentUserID else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            requests = try await requestService.requests(ownedBy: ownerID)
            summaryStore.save(.make(from: requests))   // keep Siri's summary up to date
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        await checkNotificationStatus()
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
    
    /// Suggest turning on notifications only when it's useful: you have requests and haven't decided yet.
    func checkNotificationStatus() async {
        guard let notificationService else { return }
        let status = await notificationService.authorizationStatus()
        showNotificationNudge = status == .notDetermined && !requests.isEmpty
    }

    func enableNotifications() async {
        _ = await notificationService?.requestPermission()
        await checkNotificationStatus()
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
