//
//  HelpViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation
import CoreLocation

/// "Help nearby": other people's open requests close to me.
@MainActor
@Observable
final class HelpViewModel {
    enum LocationState: Equatable { case unknown, denied, available }

    private(set) var nearby: [NearbyRequest] = []
    private(set) var locationState: LocationState = .unknown
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let requestService: RequestServicing
    private let locationService: LocationServicing
    private let authService: AuthServicing

    init(requestService: RequestServicing,
         locationService: LocationServicing,
         authService: AuthServicing) {
        self.requestService = requestService
        self.locationService = locationService
        self.authService = authService
    }

    func load() async {
        guard let userID = authService.currentUserID else { return }

        switch locationService.authorizationStatus {
        case .notDetermined:
            locationState = .unknown
            return
        case .denied, .restricted:
            locationState = .denied
            nearby = []
            return
        default:
            break
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let here = try await locationService.currentLocation()
            let open = try await requestService.openRequests()
            nearby = HelpFeed.nearby(open, from: here, excluding: userID)
            locationState = .available
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func enableLocation() async {
        _ = await locationService.requestPermission()
        await load()
    }
}
