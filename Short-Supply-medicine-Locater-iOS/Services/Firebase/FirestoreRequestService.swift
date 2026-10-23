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
}
