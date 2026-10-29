//
//  HelperLevel.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// A friendly name for a reputation range. Display only — levels unlock nothing
/// (the proposal says reputation is a trust signal, with no rewards or leaderboards).
enum HelperLevel: Int, CaseIterable {
    // rawValue = points needed to reach the level
    case newcomer = 0
    case helper   = 50
    case trusted  = 150
    case champion = 300

    var title: String {
        switch self {
        case .newcomer: "Newcomer"
        case .helper:   "Helper"
        case .trusted:  "Trusted helper"
        case .champion: "Community champion"
        }
    }

    /// The level after this one (nil at the top).
    var next: HelperLevel? {
        Self.allCases.first { $0.rawValue > rawValue }
    }

    /// The highest level the points reach.
    init(reputation: Int) {
        self = Self.allCases.last { reputation >= $0.rawValue } ?? .newcomer
    }

    /// 0.0–1.0 of the way to the next level (1.0 at the top level). Fills the ring.
    static func progress(for reputation: Int) -> Double {
        let level = HelperLevel(reputation: reputation)
        guard let next = level.next else { return 1 }
        return Double(reputation - level.rawValue) / Double(next.rawValue - level.rawValue)
    }

    /// Points still needed for the next level (nil at the top).
    static func pointsToNext(for reputation: Int) -> Int? {
        HelperLevel(reputation: reputation).next.map { $0.rawValue - reputation }
    }
    
    /// Icon on the journey ladder.
    var systemImage: String {
        switch self {
        case .newcomer: "leaf.fill"
        case .helper:   "hand.raised.fill"
        case .trusted:  "checkmark.shield.fill"
        case .champion: "star.circle.fill"
        }
    }

    /// One short line under each level on the ladder.
    var meaning: String {
        switch self {
        case .newcomer: "Everyone starts here."
        case .helper:   "You've started confirming stock for others."
        case .trusted:  "Your on-site checks help many people."
        case .champion: "One of the most active helpers in your area."
        }
    }

    /// Where a level sits on MY journey.
    enum Status: Equatable {
        case reached    // below my level — already done
        case current    // my level now
        case locked     // above my level — still to climb
    }

    /// e.g. with 60 points: Newcomer = reached, Helper = current, Trusted = locked
    func status(for reputation: Int) -> Status {
        let mine = HelperLevel(reputation: reputation)
        if self == mine { return .current }
        return rawValue < mine.rawValue ? .reached : .locked
    }
}
