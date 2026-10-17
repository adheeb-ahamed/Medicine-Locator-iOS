//
//  MedicineRequest.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import Foundation

/// A patient's anonymous "I'm looking for X" post. Stored at requests/{id}.
struct MedicineRequest: Codable, Identifiable {
    enum Status: String, Codable {
        case open       // still looking
        case found      // patient marked it found
        case expired    // 7 days passed without renewal
        case closed     // closed by the patient
    }

    let id: String
    let ownerID: String         // uid of the patient (never shown publicly)
    var medicine: Medicine
    var areaName: String        // e.g. "Colombo 07"
    var areaLatitude: Double    // blurred to roughly 5 km
    var areaLongitude: Double
    var status: Status
    var createdAt: Date
    var expiresAt: Date
    var responseCount: Int

    /// Open AND not past its expiry date.
    /// `now` is a parameter so tests can pass a fixed date.
    func isActive(at now: Date = .now) -> Bool {
        status == .open && expiresAt > now
    }

    /// Rounds a coordinate to the nearest 0.05° (about 5.5 km)
    /// so we never store the patient's exact location.
    static func blur(_ value: Double) -> Double {
        (value * 20).rounded() / 20
    }
}
