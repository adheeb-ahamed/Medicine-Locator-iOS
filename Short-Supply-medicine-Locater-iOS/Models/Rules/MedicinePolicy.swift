//
//  MedicinePolicy.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Rules about which medicines can be requested.
enum MedicinePolicy {
    /// Starter list of controlled (narcotic / psychotropic) medicines.
    /// Keep in sync with the regex in firestore.rules.
    static let controlledNames: [String] = [
        "morphine", "pethidine", "fentanyl", "oxycodone", "methadone",
        "buprenorphine", "tramadol", "codeine", "ketamine",
        "diazepam", "alprazolam", "clonazepam", "lorazepam", "midazolam",
        "methylphenidate"
    ]

    /// True if the name contains any controlled medicine ("Morphine sulfate" → true).
    static func isControlled(_ name: String) -> Bool {
        let key = Medicine.key(for: name)
        return controlledNames.contains { key.contains($0) }
    }
}
