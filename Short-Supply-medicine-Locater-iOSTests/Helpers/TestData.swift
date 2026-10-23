//
//  TestData.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreGraphics
@testable import Short_Supply_medicine_Locater_iOS

/// Fixed test data. A fixed date means tests give the same result every run.
enum TestData {
    static let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    static func response(id: String = "response-1",
                         requestID: String? = "request-1",
                         medicineKey: String = "imatinib",
                         source: AvailabilityResponse.Source = .community,
                         onSite: Bool = true,
                         stillAvailable: Int = 0,
                         soldOut: Int = 0,
                         neverHere: Int = 0,
                         createdAt: Date = t0,
                         lifetimeHours: Double = 6) -> AvailabilityResponse {
        AvailabilityResponse(
            id: id,
            requestID: requestID,
            responderID: "user-1",
            pharmacyID: "pharmacy-1",
            pharmacyName: "Test Pharmacy",
            medicineKey: medicineKey,
            medicineName: "Imatinib 400 mg",
            source: source,
            wasOnSite: onSite,
            createdAt: createdAt,
            expiresAt: createdAt + .hours(lifetimeHours),
            stillAvailableCount: stillAvailable,
            soldOutCount: soldOut,
            neverHereCount: neverHere
        )
    }
    
    /// A 1×1 image — enough to call the scanner in tests.
    static var blankImage: CGImage {
        let context = CGContext(data: nil, width: 1, height: 1,
                                bitsPerComponent: 8, bytesPerRow: 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        return context.makeImage()!
    }

    static func request(id: String = "request-1",
                        ownerID: String = "anon-user",
                        status: MedicineRequest.Status = .open,
                        expiresAt: Date = .now + .days(7)) -> MedicineRequest {
        MedicineRequest(
            id: id,
            ownerID: ownerID,
            medicine: Medicine(name: "Imatinib", strength: "400 mg", isControlled: false),
            areaName: "Colombo",
            areaLatitude: 6.9,
            areaLongitude: 79.85,
            status: status,
            createdAt: .now,
            expiresAt: expiresAt,
            responseCount: 0
        )
    }
    
    static func pharmacy(id: String = "p1",
                         name: String = "Test Pharmacy",
                         district: String = "Colombo",
                         latitude: Double = 6.9344,
                         longitude: Double = 79.8428) -> Pharmacy {
        Pharmacy(id: id, name: name, address: "Test Road", district: district,
                 latitude: latitude, longitude: longitude,
                 phone: nil, kind: .retail, isVerified: false)
    }
}
