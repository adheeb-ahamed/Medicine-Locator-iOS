//
//  Formatters.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Turns raw numbers into text people read.
enum Formatters {
    /// 850 → "850 m", 1234 → "1.2 km"
    static func distance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters.rounded())) m"
        }
        return String(format: "%.1f km", meters / 1000)
    }

        /// Time until a report disappears: "35m left", "4h left", "Expired".
    /// `now` is a parameter so tests can use a fixed time.
    static func timeLeft(until date: Date, from now: Date = .now) -> String {
        let minutes = Int(date.timeIntervalSince(now) / 60)
        if minutes <= 0 { return "Expired" }
        if minutes < 60 { return "\(minutes)m left" }
        return "\(minutes / 60)h left"
    }
}
