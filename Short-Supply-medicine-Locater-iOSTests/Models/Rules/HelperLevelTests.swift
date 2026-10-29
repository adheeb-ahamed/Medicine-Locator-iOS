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
}