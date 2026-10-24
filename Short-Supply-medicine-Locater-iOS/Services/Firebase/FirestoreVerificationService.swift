//
//  FirestoreVerificationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreVerificationService: VerificationServicing {
    private var db: Firestore { Firestore.firestore() }
    private var collection: CollectionReference { db.collection("verificationRequests") }

    func submit(_ application: VerificationRequest) async throws {
        let data = try Firestore.Encoder().encode(application)
        try await collection.document(application.id).setData(data)
    }

    func application(for userID: String) async throws -> VerificationRequest? {
        let snapshot = try await collection.document(userID).getDocument()
        return snapshot.exists ? try snapshot.data(as: VerificationRequest.self) : nil
    }

    func pendingApplications() async throws -> [VerificationRequest] {
        let snapshot = try await collection
            .whereField("status", isEqualTo: VerificationRequest.Status.pending.rawValue)
            .getDocuments()
        return snapshot.documents
            .compactMap { try? $0.data(as: VerificationRequest.self) }
            .sorted { $0.createdAt < $1.createdAt }          // oldest first — fair queue
    }

    /// Approve + promote the user to "pharmacy" in ONE batch.
    func approve(_ application: VerificationRequest, by reviewerID: String) async throws {
        let batch = db.batch()
        batch.updateData([
            "status": VerificationRequest.Status.approved.rawValue,
            "reviewerID": reviewerID,
            "reviewedAt": FieldValue.serverTimestamp()
        ], forDocument: collection.document(application.id))

        batch.updateData([
            "role": UserRole.pharmacy.rawValue,
            "pharmacyID": application.pharmacyID
        ], forDocument: db.collection("users").document(application.userID))

        try await batch.commit()
    }

    func reject(_ application: VerificationRequest, by reviewerID: String, note: String) async throws {
        try await collection.document(application.id).updateData([
            "status": VerificationRequest.Status.rejected.rawValue,
            "reviewerID": reviewerID,
            "reviewedAt": FieldValue.serverTimestamp(),
            "note": note
        ])
    }
}
