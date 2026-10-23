//
//  MockRequestService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockRequestService: RequestServicing {
    var stored: [MedicineRequest] = []

    func create(_ request: MedicineRequest) async throws {
        stored.append(request)
    }

    func requests(ownedBy ownerID: String) async throws -> [MedicineRequest] {
        stored.filter { $0.ownerID == ownerID }
    }

    func setStatus(_ status: MedicineRequest.Status, foundResponseID: String?, for requestID: String) async throws {
        guard let index = stored.firstIndex(where: { $0.id == requestID }) else { return }
        stored[index].status = status
        stored[index].foundResponseID = foundResponseID
    }

    func renew(_ requestID: String, until expiresAt: Date) async throws {
        guard let index = stored.firstIndex(where: { $0.id == requestID }) else { return }
        stored[index].status = .open
        stored[index].expiresAt = expiresAt
    }
    
    func openRequests() async throws -> [MedicineRequest] {
        stored.filter { $0.status == .open }
    }

    func markFound(_ requestID: String, via response: AvailabilityResponse?, by ownerID: String) async throws {
        guard let index = stored.firstIndex(where: { $0.id == requestID }) else { return }
        stored[index].status = .found
        stored[index].foundResponseID = response?.id
    }
}

@MainActor
final class MockResponseService: ResponseServicing {
    var responses: [AvailabilityResponse] = []
    var votes: [String: Confirmation.Verdict] = [:]       // "responseID|userID" → verdict

    func responses(forMedicineKey key: String) async throws -> [AvailabilityResponse] {
        responses.filter { $0.medicineKey == key }
    }

    func responses(forRequestID id: String) async throws -> [AvailabilityResponse] {
        responses.filter { $0.requestID == id }
    }

    func create(_ response: AvailabilityResponse) async throws {
        responses.append(response)
    }

    func hasVoted(on responseID: String, userID: String) async throws -> Bool {
        votes["\(responseID)|\(userID)"] != nil
    }

    func vote(_ verdict: Confirmation.Verdict, on response: AvailabilityResponse, by userID: String) async throws {
        votes["\(response.id)|\(userID)"] = verdict
        let outcome = VoteRules.apply(verdict, by: userID, to: response)
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            responses[index] = outcome.updatedResponse
        }
    }
}
