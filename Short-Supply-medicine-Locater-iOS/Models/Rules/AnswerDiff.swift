//
//  AnswerDiff.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Which answers are new since the last check?
enum AnswerDiff {
    /// `seen == nil` means "first check ever": remember everything, notify nothing
    /// (otherwise the user gets a burst of old notifications).
    static func compare(current: [AvailabilityResponse],
                        seen: Set<String>?) -> (toNotify: [AvailabilityResponse], updatedSeen: Set<String>) {
        let currentIDs = Set(current.map(\.id))
        guard let seen else {
            return ([], currentIDs)
        }
        let new = current.filter { !seen.contains($0.id) }
        return (new, seen.union(currentIDs))
    }
}
