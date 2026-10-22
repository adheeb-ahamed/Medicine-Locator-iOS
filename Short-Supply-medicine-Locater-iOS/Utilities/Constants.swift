//
//  Constants.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Every tunable number from the proposal, in one place.
enum Constants {

    enum Location {
        /// You must be within this many metres of a pharmacy to vote on-site.
        static let onSiteRadius: Double = 100
    }

    enum Lifetime {
        static let request: TimeInterval              = .days(7)
        static let communityResponse: TimeInterval    = .hours(6)
        static let confirmationExtension: TimeInterval = .hours(2)
        static let communityResponseMax: TimeInterval = .hours(12)
    }

    enum Closing {
        /// On-site "Sold out now" votes needed to close a response.
        static let soldOutVotesToClose = 2
        /// On-site "It was never here" votes needed to mark a response false.
        static let neverHereVotesToClose = 2
    }
}

extension TimeInterval {
    /// Lets us write .hours(6) instead of 6 * 60 * 60.
    static func hours(_ value: Double) -> TimeInterval { value * 60 * 60 }
    static func days(_ value: Double) -> TimeInterval { value * 24 * 60 * 60 }
}
