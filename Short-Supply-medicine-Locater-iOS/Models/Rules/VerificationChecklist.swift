//
//  VerificationChecklist.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// The moderator's checklist. Approve is only possible when everything is true.
enum VerificationChecklist {

    /// The licence number typed by the applicant must match the pharmacy they picked
    /// from the NMRA list (our pharmacy IDs ARE licence numbers). Ignores case, spaces and dashes.
    static func licenceMatches(_ application: VerificationRequest) -> Bool {
        normalise(application.licenceNumber) == normalise(application.pharmacyID)
    }

    static func canApprove(_ application: VerificationRequest, calledPublicNumber: Bool) -> Bool {
        application.status == .pending
            && licenceMatches(application)
            && calledPublicNumber
    }

    /// "nmra-123 45" → "NMRA12345"
    static func normalise(_ text: String) -> String {
        text.uppercased().filter { $0.isLetter || $0.isNumber }
    }
}
