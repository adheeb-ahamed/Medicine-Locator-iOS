//
//  UserProfile.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import Foundation

// User roles and where permissions differ
// All the normal users are members

enum UserRole: String, Codable {
    case member      // every normal user: can request AND help
    case pharmacy    // verified by a moderator
    case moderator   // set by hand in the Firebase console

    var displayName: String {
        switch self {
        case .member:    "Member"
        case .pharmacy:  "Verified pharmacy"
        case .moderator: "Moderator"
        }
    }
}

/// Stored in Firestore at users
struct UserProfile: Codable, Identifiable, Equatable {
    let id: String          // same as the Firebase Auth uid
    var role: UserRole
    var reputation: Int
    var email: String?      // nil = anonymous
    var createdAt: Date
    var pharmacyID: String?    // set when a moderator approves this user as a pharmacy

    /// Anonymous users can still request and help.
    /// Linking an email only keeps their reputation safe if they change phones.
    var isAnonymous: Bool { email == nil }
}
