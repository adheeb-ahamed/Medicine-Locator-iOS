//
//  FirestoreUserService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import Foundation
import FirebaseFirestore

/// Reads/writes users/{uid} in Firestore.
@MainActor
final class FirestoreUserService: UserServicing {
    private var db: Firestore { Firestore.firestore() }

    func fetchOrCreateProfile(uid: String, email: String?) async throws -> UserProfile {
        let ref = db.collection("users").document(uid)
        let snapshot = try await ref.getDocument()

        // Existing user: load it, and save the email if they just linked one.
        if snapshot.exists {
            var profile = try snapshot.data(as: UserProfile.self)
            if let email, profile.email != email {
                profile.email = email
                try await ref.updateData(["email": email])
            }
            return profile
        }

        // First time we've seen this uid: create a plain member profile.
        let profile = UserProfile(
            id: uid,
            role: .member,
            reputation: 0,
            email: email,
            createdAt: Date()
        )
        try ref.setData(from: profile)
        return profile
    }
    
    func deleteProfile(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }
}
