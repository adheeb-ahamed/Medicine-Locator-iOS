//
//  ArrivalCooldown.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Don't nag: at most one arrival prompt per pharmacy every 12 hours.
enum ArrivalCooldown {
    static let interval: TimeInterval = .hours(12)

    static func shouldNotify(lastNotified: Date?, now: Date = .now) -> Bool {
        guard let lastNotified else { return true }
        return now.timeIntervalSince(lastNotified) >= interval
    }
}
