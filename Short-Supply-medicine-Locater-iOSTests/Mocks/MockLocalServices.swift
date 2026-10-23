//
//  MockLocalServices.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreLocation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockPharmacyService: PharmacyServicing {
    var pharmacies: [Pharmacy] = []
    func loadPharmacies() throws -> [Pharmacy] { pharmacies }
}

@MainActor
final class MockLocationService: LocationServicing {
    var authorizationStatus: CLAuthorizationStatus
    var statusAfterRequest: CLAuthorizationStatus
    var location = CLLocation(latitude: 6.9344, longitude: 79.8428)   // Colombo Fort

    init(status: CLAuthorizationStatus, statusAfterRequest: CLAuthorizationStatus = .authorizedWhenInUse) {
        self.authorizationStatus = status
        self.statusAfterRequest = statusAfterRequest
    }

    func requestPermission() async -> CLAuthorizationStatus {
        if authorizationStatus == .notDetermined { authorizationStatus = statusAfterRequest }
        return authorizationStatus
    }

    func currentLocation() async throws -> CLLocation { location }
}

@MainActor
final class MockSearchHistoryService: SearchHistoryServicing {
    private(set) var items: [String] = []
    func recentSearches() -> [String] { items }
    func record(_ query: String) {
        items.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
        items.insert(query, at: 0)
    }
    func delete(_ query: String) { items.removeAll { $0 == query } }
    func clearAll() { items = [] }
}
