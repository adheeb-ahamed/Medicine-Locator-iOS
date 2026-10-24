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
}