//
//  VerificationRequest.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// "I run this pharmacy" application. Stored at verificationRequests/{userID}
struct VerificationRequest: Codable, Identifiable, Equatable {
    enum Status: String, Codable {
        case pending, approved, rejected

        var label: String {
            switch self {
            case .pending:  "Waiting for review"
            case .approved: "Approved"
            case .rejected: "Not approved"
            }
        }
    }

    let id: String              // = applicant's userID → one application per person
    let userID: String
    var pharmacyID: String      // chosen from the licensed list
    var pharmacyName: String
    var licenceNumber: String   // typed by the applicant — must match pharmacyID
    var contactName: String
    var phone: String
    var status: Status
    var createdAt: Date
    var reviewerID: String?
    var reviewedAt: Date?
    var note: String?           // reason when rejected
}
