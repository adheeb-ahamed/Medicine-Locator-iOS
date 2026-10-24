//
//  ModeratorViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct ModeratorViewModelTests {

    private func makeSUT() -> (ModeratorViewModel, MockVerificationService) {
        let verification = MockVerificationService()
        verification.stored = [
            "a": TestData.application(id: "a"),
            "b": TestData.application(id: "b", status: .approved)
        ]
        return (ModeratorViewModel(moderatorID: "mod",
                                   verificationService: verification,
                                   pharmacyService: MockPharmacyService()), verification)
    }

    @Test func queueShowsOnlyPending() async {
        let (vm, _) = makeSUT()
        await vm.load()
        #expect(vm.queue.map(\.id) == ["a"])
    }

    @Test func cannotApproveWithoutTheCall() async {
        let (vm, verification) = makeSUT()
        await vm.load()
        let approved = await vm.approve(vm.queue[0], calledPublicNumber: false)
        #expect(!approved)
        #expect(verification.stored["a"]?.status == .pending)
    }

    @Test func approvingRemovesFromQueue() async {
        let (vm, verification) = makeSUT()
        await vm.load()
        let approved = await vm.approve(vm.queue[0], calledPublicNumber: true)
        #expect(approved)
        #expect(verification.stored["a"]?.reviewerID == "mod")
        #expect(vm.queue.isEmpty)
    }

    @Test func rejectingStoresTheReason() async {
        let (vm, verification) = makeSUT()
        await vm.load()
        _ = await vm.reject(vm.queue[0], note: "Couldn't reach the pharmacy")
        #expect(verification.stored["a"]?.status == .rejected)
        #expect(verification.stored["a"]?.note == "Couldn't reach the pharmacy")
    }
}