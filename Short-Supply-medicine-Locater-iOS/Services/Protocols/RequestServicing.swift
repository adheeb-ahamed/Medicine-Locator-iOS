//
//  RequestServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

@MainActor
protocol RequestServicing {
    func create(_ request: MedicineRequest) async throws
    func requests(ownedBy ownerID: String) async throws -> [MedicineRequest]
    func setStatus(_ status: MedicineRequest.Status,
                   foundResponseID: String?,
                   for requestID: String) async throws
    func renew(_ requestID: String, until expiresAt: Date) async throws
}
