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
    private var collection: CollectionReference {
        Firestore.firestore().collection("responses")
    }

    func responses(forMedicineKey key: String) async throws -> [AvailabilityResponse] {
        try await fetch(collection.whereField("medicineKey", isEqualTo: key))
    }

    func responses(forRequestID id: String) async throws -> [AvailabilityResponse] {
        try await fetch(collection.whereField("requestID", isEqualTo: id))
    }

    private func fetch(_ query: Query) async throws -> [AvailabilityResponse] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: AvailabilityResponse.self) }
    }
}
