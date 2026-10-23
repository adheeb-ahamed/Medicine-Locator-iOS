//
//  FirestoreReputationService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreReputationService: ReputationServicing {
    func entries(for userID: String) async throws -> [ReputationEntry] {
        let snapshot = try await Firestore.firestore()
            .collection("reputationEvents")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: ReputationEntry.self) }
    }
}
