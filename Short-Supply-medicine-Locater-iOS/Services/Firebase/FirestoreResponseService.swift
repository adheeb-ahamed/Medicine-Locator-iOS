//
//  FirestoreResponseService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreResponseService: ResponseServicing {
    private var db: Firestore { Firestore.firestore() }
    private var collection: CollectionReference { db.collection("responses") }

    // MARK: - Reading

    func responses(forMedicineKey key: String) async throws -> [AvailabilityResponse] {
        try await fetch(collection.whereField("medicineKey", isEqualTo: key))
    }

    func responses(forRequestID id: String) async throws -> [AvailabilityResponse] {
        try await fetch(collection.whereField("requestID", isEqualTo: id))
    }

    func hasVoted(on responseID: String, userID: String) async throws -> Bool {
        try await collection.document(responseID)
            .collection("confirmations").document(userID)
            .getDocument().exists
    }

    // MARK: - Writing

    func create(_ response: AvailabilityResponse) async throws {
        let data = try Firestore.Encoder().encode(response)
        try await collection.document(response.id).setData(data)
    }

    /// One atomic batch: confirmation + counter + expiry + reputation entries.
    func vote(_ verdict: Confirmation.Verdict,
              on response: AvailabilityResponse,
              by userID: String) async throws {
        let outcome = VoteRules.apply(verdict, by: userID, to: response)
        let responseRef = collection.document(response.id)
        let batch = db.batch()

        // 1. The vote (document ID = voter → one vote per person)
        try batch.setData(from: outcome.confirmation,
                          forDocument: responseRef.collection("confirmations").document(userID))

        // 2. +1 on the right counter (increment is safe if two people vote at once)
        var fields: [String: Any] = [verdict.countField: FieldValue.increment(Int64(1))]
        if outcome.updatedResponse.expiresAt != response.expiresAt {
            fields["expiresAt"] = outcome.updatedResponse.expiresAt
        }
        batch.updateData(fields, forDocument: responseRef)

        // 3. Reputation ledger entries
        for entry in outcome.reputationEntries {
            try batch.setData(from: entry,
                              forDocument: db.collection("reputationEvents").document(entry.id))
        }

        // All or nothing
        try await batch.commit()
    }

    private func fetch(_ query: Query) async throws -> [AvailabilityResponse] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: AvailabilityResponse.self) }
    }
}
