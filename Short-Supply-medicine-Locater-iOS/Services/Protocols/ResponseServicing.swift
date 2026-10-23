//
//  ResponseServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Reading responses now; writing them is added in Phase 6.
@MainActor
protocol ResponseServicing {
    func responses(forMedicineKey key: String) async throws -> [AvailabilityResponse]
    func responses(forRequestID id: String) async throws -> [AvailabilityResponse]
}
