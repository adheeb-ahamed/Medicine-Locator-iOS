//
//  ResponseServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

@MainActor
protocol ResponseServicing {
    func responses(forMedicineKey key: String) async throws -> [AvailabilityResponse]
    func responses(forRequestID id: String) async throws -> [AvailabilityResponse]
    func create(_ response: AvailabilityResponse) async throws                          
    func hasVoted(on responseID: String, userID: String) async throws -> Bool
    func vote(_ verdict: Confirmation.Verdict,
              on response: AvailabilityResponse,
              by userID: String) async throws
}
