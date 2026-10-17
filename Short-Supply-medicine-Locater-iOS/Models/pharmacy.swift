//
//  pharmacy.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import Foundation
import CoreLocation

/// A licensed pharmacy (from the NMRA list or MapKit search).
struct Pharmacy: Codable, Identifiable, Hashable {
    enum Kind: String, Codable {
        case retail
        case hospital
    }

    let id: String          // NMRA licence number
    var name: String
    var address: String
    var district: String
    var latitude: Double
    var longitude: Double
    var phone: String?
    var kind: Kind
    var isVerified: Bool    // true once a moderator approves the pharmacy account

    /// MapKit and Core Location use CLLocationCoordinate2D.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Distance in metres from the user (used for the 100 m on-site check).
    func distance(from location: CLLocation) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: location)
    }
}

#if DEBUG
extension Pharmacy {
    /// Made-up data for SwiftUI previews only.
    static let samples: [Pharmacy] = [
        Pharmacy(id: "SAMPLE-001", name: "Sample City Pharmacy", address: "12 Galle Road",
                 district: "Colombo", latitude: 6.9022, longitude: 79.8607,
                 phone: nil, kind: .retail, isVerified: true),
        Pharmacy(id: "SAMPLE-002", name: "Sample Hospital Pharmacy", address: "Ward Place",
                 district: "Colombo", latitude: 6.9175, longitude: 79.8687,
                 phone: nil, kind: .hospital, isVerified: false)
    ]
}
#endif
