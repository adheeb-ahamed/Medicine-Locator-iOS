//
//  FirestoreRequestService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreRequestService: RequestServicing {
    private var collection: CollectionReference {
        Firestore.firestore().collection("requests")
    }

    func create(_ request: MedicineRequest) async throws {
        // Encode the struct to a Firestore dictionary, then wait for the server to accept it.
        let data = try Firestore.Encoder().encode(request)
        try await collection.document(request.id).setData(data)
    }

    func requests(ownedBy ownerID: String) async throws -> [MedicineRequest] {
        let snapshot = try await collection
            .whereField("ownerID", isEqualTo: ownerID)
            .getDocuments()
        return snapshot.documents
            .compactMap { try? $0.data(as: MedicineRequest.self) }
            .sorted { $0.createdAt > $1.createdAt }          // newest first
    }

    func setStatus(_ status: MedicineRequest.Status,
                   foundResponseID: String?,
                   for requestID: String) async throws {
        var fields: [String: Any] = ["status": status.rawValue]
        if let foundResponseID {
            fields["foundResponseID"] = foundResponseID
        } else {
            fields["foundResponseID"] = FieldValue.delete()
        }
        try await collection.document(requestID).updateData(fields)
    }

    func renew(_ requestID: String, until expiresAt: Date) async throws {
        try await collection.document(requestID).updateData([
            "status": MedicineRequest.Status.open.rawValue,
            "expiresAt": expiresAt
        ])
    }
    
    func openRequests() async throws -> [MedicineRequest] {
        let snapshot = try await collection
            .whereField("status", isEqualTo: MedicineRequest.Status.open.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MedicineRequest.self) }
    }

    /// Mark found and, if a response helped, give its author +25 — in one batch.
    func markFound(_ requestID: String,
                   via response: AvailabilityResponse?,
                   by ownerID: String) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()

        var fields: [String: Any] = ["status": MedicineRequest.Status.found.rawValue]
        if let response {
            fields["foundResponseID"] = response.id
        } else {
            fields["foundResponseID"] = FieldValue.delete()
        }
        batch.updateData(fields, forDocument: collection.document(requestID))

        if let response, response.responderID != ownerID {
            let entry = ReputationEntry(id: "found_\(requestID)_\(response.id)",
                                        userID: response.responderID,
                                        reason: .responseMarkedFound,
                                        responseID: response.id,
                                        requestID: requestID,
                                        createdAt: .now)
            try batch.setData(from: entry,
                              forDocument: db.collection("reputationEvents").document(entry.id))
        }

        try await batch.commit()
    }
}
