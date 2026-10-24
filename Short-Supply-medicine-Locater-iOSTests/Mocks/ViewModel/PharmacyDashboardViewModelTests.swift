//
//  PharmacyDashboardViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct PharmacyDashboardViewModelTests {

    private func makeSUT(role: UserRole = .pharmacy) -> (PharmacyDashboardViewModel, MockResponseService) {
        let pharmacies = MockPharmacyService()
        pharmacies.pharmacies = [TestData.pharmacy(id: "NMRA-123", name: "My Pharmacy")]
        let responses = MockResponseService()
        let vm = PharmacyDashboardViewModel(
            profile: TestData.profile(id: "pharm-user", role: role, pharmacyID: "NMRA-123"),
            responseService: responses,
            pharmacyService: pharmacies)
        return (vm, responses)
    }

    @Test func postIsAVerifiedOnSitePostForOwnPharmacy() async throws {
        let (vm, responses) = makeSUT()
        await vm.load()
        vm.medicineName = "Imatinib"
        vm.strength = "400 mg"
        vm.duration = .twentyFourHours
        await vm.post()

        let post = try #require(responses.responses.first)
        #expect(post.source == .verifiedPharmacy)
        #expect(post.requestID == nil)
        #expect(post.pharmacyID == "NMRA-123")
        #expect(post.wasOnSite)
        #expect(post.medicineKey == "imatinib")
        #expect(post.expiresAt.timeIntervalSince(post.createdAt) == .hours(24))
        #expect(vm.livePosts.count == 1)
    }

    @Test func controlledMedicinesCannotBePosted() async {
        let (vm, responses) = makeSUT()
        await vm.load()
        vm.medicineName = "Tramadol"
        #expect(!vm.canPost)
        await vm.post()
        #expect(responses.responses.isEmpty)
    }

    @Test func membersCannotPostAsPharmacy() async {
        let (vm, _) = makeSUT(role: .member)
        await vm.load()
        vm.medicineName = "Imatinib"
        #expect(!vm.canPost)
    }

    @Test func soldOutHidesThePost() async {
        let (vm, _) = makeSUT()
        await vm.load()
        vm.medicineName = "Imatinib"
        await vm.post()
        await vm.markSoldOut(vm.livePosts[0])
        #expect(vm.livePosts.isEmpty)
    }
}