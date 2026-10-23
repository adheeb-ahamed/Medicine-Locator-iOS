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

    /// Builds a SearchViewModel whose sources use mock services.
    private func makeSUT(_ history: MockSearchHistoryService? = nil) -> SearchViewModel {
        SearchViewModel(historyService: history ?? MockSearchHistoryService()) { key in
            SourcesViewModel(scope: .medicine(key: key),
                             responseService: MockResponseService(),
                             pharmacyService: MockPharmacyService())
        }
    }

    @Test func submitTrimsAndRecords() {
        let vm = makeSUT()
        vm.query = "  Imatinib  "
        vm.submit()
        #expect(vm.submittedQuery == "Imatinib")
        #expect(vm.history == ["Imatinib"])
    }

    @Test func emptySearchIsIgnored() {
        let vm = makeSUT()
        vm.query = "   "
        vm.submit()
        #expect(vm.submittedQuery == nil)
        #expect(vm.history.isEmpty)
        #expect(vm.sources == nil)
    }

    @Test func selectingHistoryRunsItAgainAtTheTop() {
        let vm = makeSUT()
        vm.query = "Tamoxifen"; vm.submit()
        vm.query = "Imatinib";  vm.submit()
        vm.select("Tamoxifen")
        #expect(vm.query == "Tamoxifen")
        #expect(vm.history == ["Tamoxifen", "Imatinib"])
    }

    @Test func clearHistoryEmptiesTheList() {
        let vm = makeSUT()
        vm.query = "Imatinib"; vm.submit()
        vm.clearHistory()
        #expect(vm.history.isEmpty)
    }

    @Test func submittingCreatesSourcesForTheNormalisedKey() {
        let vm = makeSUT()
        vm.query = "  Imatinib "
        vm.submit()
        #expect(vm.sources?.scope == .medicine(key: "imatinib"))
    }

    @Test func clearingTheResultRemovesSources() {
        let vm = makeSUT()
        vm.query = "Imatinib"; vm.submit()
        vm.clearResult()
        #expect(vm.submittedQuery == nil)
        #expect(vm.sources == nil)
    }
}
