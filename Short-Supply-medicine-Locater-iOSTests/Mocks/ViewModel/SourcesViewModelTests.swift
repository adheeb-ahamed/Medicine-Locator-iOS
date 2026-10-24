//
//  SourcesViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct SourcesViewModelTests {

    @Test func requestShowsItsAnswersPlusPharmacyPostsForTheSameMedicine() async {
        let responses = MockResponseService()
        responses.responses = [
            TestData.response(id: "answer", requestID: "request-1", createdAt: .now),
            TestData.response(id: "pharmacy", requestID: nil, source: .verifiedPharmacy, createdAt: .now),
            TestData.response(id: "other-request", requestID: "request-2", createdAt: .now)
        ]
        let vm = SourcesViewModel(scope: .request(id: "request-1", medicineKey: "imatinib"),
                                  responseService: responses,
                                  pharmacyService: MockPharmacyService())
        await vm.load()

        #expect(vm.sources.map(\.id) == ["pharmacy", "answer"])    // 0.90 first, then 0.55
    }
    
    @Test func onlineResultsAreSavedForLater() async {
        let responses = MockResponseService()
        responses.responses = [TestData.response(id: "r1", createdAt: .now)]
        let cache = MockSourceCache()
        let vm = SourcesViewModel(scope: .medicine(key: "imatinib"),
                                  responseService: responses,
                                  pharmacyService: MockPharmacyService(),
                                  connectivity: MockConnectivityService(),
                                  cache: cache)
        await vm.load()

        #expect(cache.saved["medicine:imatinib"]?.map(\.id) == ["r1"])
        #expect(!vm.isOffline)
    }

    @Test func offlineShowsSavedUnexpiredResults() async {
        let cache = MockSourceCache()
        let fresh = SourceSnapshot(id: "fresh", pharmacyID: "p", pharmacyName: "Fresh", medicineName: "Imatinib",
                                   score: 0.7, wasOnSite: true, expiresAt: .now + .hours(2), cachedAt: .now)
        let stale = SourceSnapshot(id: "stale", pharmacyID: "p", pharmacyName: "Stale", medicineName: "Imatinib",
                                   score: 0.9, wasOnSite: true, expiresAt: .now - .hours(1), cachedAt: .now)
        cache.saved["medicine:imatinib"] = [stale, fresh]

        let offline = MockConnectivityService()
        offline.isNetworkAvailable = false

        let vm = SourcesViewModel(scope: .medicine(key: "imatinib"),
                                  responseService: MockResponseService(),
                                  pharmacyService: MockPharmacyService(),
                                  connectivity: offline,
                                  cache: cache)
        await vm.load()

        #expect(vm.isOffline)
        #expect(vm.sources.isEmpty)
        #expect(vm.cached.map(\.id) == ["fresh"])          // expired one is hidden
    }
}
