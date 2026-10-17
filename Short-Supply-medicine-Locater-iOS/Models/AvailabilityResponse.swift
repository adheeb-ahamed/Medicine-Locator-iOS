//
//  AvailabilityResponse.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-18.
//

import Foundation

/// "Pharmacy X has it". Stored at requests/{requestID}/responses/{id}
struct AvailabilityResponse: Codable, Identifiable {
    enum Source: String, Codable {
        case community          // a helper
        case verifiedPharmacy   // the pharmacy itself
    }

    let id: String
    let requestID: String
    let responderID: String
    let pharmacyID: String      // must be a licensed pharmacy — no free text
    var pharmacyName: String    // copied here so lists don't need a second lookup
    var source: Source
    var wasOnSite: Bool         // false → show "Not confirmed on-site"
    var createdAt: Date
    var expiresAt: Date         // 6h, extended by on-site confirmations up to 12h

    // Vote counts, updated whenever someone confirms
    var stillAvailableCount: Int
    var soldOutCount: Int
    var neverHereCount: Int

    func isLive(at now: Date = .now) -> Bool {
        expiresAt > now
    }
}
