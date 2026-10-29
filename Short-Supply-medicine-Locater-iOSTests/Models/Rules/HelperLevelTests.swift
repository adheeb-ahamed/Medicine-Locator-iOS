//
//  HelperLevelTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct HelperLevelTests {

    @Test(arguments: zip([0, 49, 50, 149, 150, 300, 1_000],
                         [HelperLevel.newcomer, .newcomer, .helper, .helper, .trusted, .champion, .champion]))
    func levelForPoints(points: Int, expected: HelperLevel) {
        #expect(HelperLevel(reputation: points) == expected)
    }

    @Test func progressIsHalfwayAt25() {
        #expect(HelperLevel.progress(for: 25) == 0.5)       // 25 of the 50 needed for Helper
    }

    @Test func topLevelIsFullAndHasNoNext() {
        #expect(HelperLevel.progress(for: 500) == 1)
        #expect(HelperLevel.pointsToNext(for: 500) == nil)
    }

    @Test func pointsToNextLevel() {
        #expect(HelperLevel.pointsToNext(for: 120) == 30)   // 150 − 120
    }
    
    @Test func journeyStatusAt60Points() {
        // 60 points = Helper
        #expect(HelperLevel.newcomer.status(for: 60) == .reached)
        #expect(HelperLevel.helper.status(for: 60) == .current)
        #expect(HelperLevel.trusted.status(for: 60) == .locked)
        #expect(HelperLevel.champion.status(for: 60) == .locked)
    }

    @Test func exactlyOnTheBoundaryIsCurrent() {
        // 150 points = exactly Trusted helper, so it's "current", not "locked"
        #expect(HelperLevel.trusted.status(for: 150) == .current)
        #expect(HelperLevel.helper.status(for: 150) == .reached)
    }
}
