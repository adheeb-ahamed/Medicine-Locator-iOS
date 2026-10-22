//
//  ExpiaryPolicy.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// How long requests and responses stay visible.
enum ExpiryPolicy {

    /// Requests last 7 days. Renewing = calling this again with today's date.
    static func requestExpiry(from date: Date) -> Date {
        date + Constants.Lifetime.request
    }

    /// Community responses: 6 h, +2 h per on-site "Still available", never more than 12 h total.
    static func communityResponseExpiry(createdAt: Date, onSiteConfirmations: Int) -> Date {
        let extensions = Double(max(onSiteConfirmations, 0)) * Constants.Lifetime.confirmationExtension
        let lifetime = min(Constants.Lifetime.communityResponse + extensions,
                           Constants.Lifetime.communityResponseMax)
        return createdAt + lifetime
    }

    /// Verified pharmacies pick 6, 12 or 24 hours.
    static func pharmacyPostExpiry(createdAt: Date, duration: PharmacyPostDuration) -> Date {
        createdAt + duration.interval
    }
}

/// The three choices a verified pharmacy gets when posting stock.
enum PharmacyPostDuration: Int, CaseIterable, Codable, Identifiable {
    case sixHours = 6
    case twelveHours = 12
    case twentyFourHours = 24

    var id: Int { rawValue }
    var interval: TimeInterval { .hours(Double(rawValue)) }
    var label: String { "\(rawValue) hours" }
}
