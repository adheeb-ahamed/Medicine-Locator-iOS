//
//  SearchViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct SearchViewModelTests {

    @Test func submitTrimsAndRecords() {
        let history = MockSearchHistoryService()
        let vm = SearchViewModel(historyService: history)
        vm.query = "  Imatinib  "
        vm.submit()
        #expect(vm.submittedQuery == "Imatinib")
        #expect(vm.history == ["Imatinib"])
    }

    @Test func emptySearchIsIgnored() {
        let history = MockSearchHistoryService()
        let vm = SearchViewModel(historyService: history)
        vm.query = "   "
        vm.submit()
        #expect(vm.submittedQuery == nil)
        #expect(vm.history.isEmpty)
    }

    @Test func selectingHistoryRunsItAgainAtTheTop() {
        let history = MockSearchHistoryService()
        let vm = SearchViewModel(historyService: history)
        vm.query = "Tamoxifen"; vm.submit()
        vm.query = "Imatinib";  vm.submit()
        vm.select("Tamoxifen")
        #expect(vm.query == "Tamoxifen")
        #expect(vm.history == ["Tamoxifen", "Imatinib"])
    }

    @Test func clearHistoryEmptiesTheList() {
        let history = MockSearchHistoryService()
        let vm = SearchViewModel(historyService: history)
        vm.query = "Imatinib"; vm.submit()
        vm.clearHistory()
        #expect(vm.history.isEmpty)
    }
}
