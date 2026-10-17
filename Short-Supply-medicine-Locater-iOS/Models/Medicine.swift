//
//  Medicine.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import Foundation

struct Medicine: Codable, Hashable, Identifiable {
    var name: String          // e.g. "Imatinib"
    var strength: String      // e.g. "400 mg"
    var isControlled: Bool    // controlled medicines can't be requested (privacy/legal)

    /// Built from name + strength, so the same medicine always gets the same id.
    var id: String {
        "\(name.lowercased())-\(strength.lowercased())"
    }

    var displayName: String {
        strength.isEmpty ? name : "\(name) \(strength)"
    }
}
