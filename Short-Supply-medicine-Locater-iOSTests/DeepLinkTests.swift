//
//  DeepLinkTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  DeepLinkTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct DeepLinkTests {

    // The exact links the widget uses must open the right tab.
    @Test(arguments: zip(["medicinelocator://requests", "medicinelocator://home"],
                         [AppSection.requests, .home]))
    func widgetLinksOpenTheRightSection(link: String, expected: AppSection) throws {
        let url = try #require(URL(string: link))
        #expect(DeepLink.section(for: url) == expected)
    }

    @Test func wrongSchemeIsIgnored() throws {
        let url = try #require(URL(string: "https://requests"))
        #expect(DeepLink.section(for: url) == nil)
    }

    @Test func unknownPageIsIgnored() throws {
        let url = try #require(URL(string: "medicinelocator://settings"))
        #expect(DeepLink.section(for: url) == nil)
    }
}