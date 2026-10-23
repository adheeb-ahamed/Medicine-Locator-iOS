//
//  AvailabilityResponse.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-18.
//

import Foundation

/// "Pharmacy X has it." Stored at responses/{id}
struct AvailabilityResponse: Codable, Identifiable {
    enum Source: String, Codable {
        case community          // a member
        case verifiedPharmacy   // the pharmacy itself
    }

    let id: String
    let requestID: String?      // nil = a pharmacy post not tied to a request (Phase 9)
    let responderID: String
    let pharmacyID: String      // must be a licensed pharmacy — no free text
    var pharmacyName: String    // copied here so lists don't need a second lookup
    var medicineKey: String     // Medicine.key — used to search all reports of a medicine
    var medicineName: String    // for display, e.g. "Imatinib 400 mg"
    var source: Source
    var wasOnSite: Bool         // false → "Not confirmed on-site"
    var createdAt: Date
    var expiresAt: Date

    var stillAvailableCount: Int
    var soldOutCount: Int
    var neverHereCount: Int

    func isLive(at now: Date = .now) -> Bool { expiresAt > now }
}
