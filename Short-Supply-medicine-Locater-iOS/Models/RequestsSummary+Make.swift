//
//  RequestsSummary+Make.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//

//
//  RequestsSummary+Make.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// App-only part: builds the summary from MedicineRequest
/// (the widget doesn't know about MedicineRequest, so this can't live in the shared file).
extension RequestsSummary {
    /// Build from the full list — only OPEN requests count.
    static func make(from requests: [MedicineRequest], now: Date = .now) -> RequestsSummary {
        let open = requests.filter { $0.effectiveStatus(at: now) == .open }
        return RequestsSummary(
            activeCount: open.count,
            answerCount: open.reduce(0) { $0 + $1.responseCount },
            medicineNames: open.map { $0.medicine.displayName },
            updatedAt: now
        )
    }
}
