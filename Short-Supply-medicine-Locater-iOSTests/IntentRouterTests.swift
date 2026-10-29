//
//  IntentRouterTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  IntentRouterTests.swift
//  Short-Supply-medicine-Locater-iOSTests
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct IntentRouterTests {

    @Test func searchGoesToHomeWithTrimmedName() {
        let router = IntentRouter()          // a fresh one, not .shared
        router.openSearch(for: "  Imatinib ")
        #expect(router.pendingSection == .home)
        #expect(router.pendingSearch == "Imatinib")
    }

    @Test func emptySearchIsIgnored() {
        let router = IntentRouter()
        router.openSearch(for: "   ")
        #expect(router.pendingSection == nil)
        #expect(router.pendingSearch == nil)
    }

    @Test func openSection() {
        let router = IntentRouter()
        router.open(.requests)
        #expect(router.pendingSection == .requests)
    }
}