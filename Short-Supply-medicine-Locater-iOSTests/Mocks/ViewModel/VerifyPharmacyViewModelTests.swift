//
//  VerifyPharmacyViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct VerifyPharmacyViewModelTests {

    private func makeSUT(profile: UserProfile) -> (VerifyPharmacyViewModel, MockVerificationService) {
        let pharmacies = MockPharmacyService()
        pharmacies.pharmacies = [TestData.pharmacy(id: "NMRA-123")]
        let verification = MockVerificationService()
        return (VerifyPharmacyViewModel(profile: profile,
                                        verificationService: verification,
                                        pharmacyService: pharmacies), verification)
    }

    private func fillForm(_ vm: VerifyPharmacyViewModel) {
        vm.selectedPharmacyID = "NMRA-123"
        vm.licenceNumber = "NMRA-123"
        vm.contactName = "A. Perera"
        vm.phone = "077 123 4567"
    }

    @Test func anonymousUsersCannotApply() async {
        let (vm, _) = makeSUT(profile: TestData.profile(email: nil))
        await vm.load()
        fillForm(vm)
        #expect(!vm.canApply)
        #expect(!vm.canSubmit)
    }

    @Test func shortPhoneIsInvalid() async {
        let (vm, _) = makeSUT(profile: TestData.profile())
        await vm.load()
        fillForm(vm)
        vm.phone = "1234"
        #expect(!vm.isValid)
    }

    @Test func submittingCreatesPendingApplicationKeyedByUser() async throws {
        let (vm, verification) = makeSUT(profile: TestData.profile(id: "me"))
        await vm.load()
        fillForm(vm)
        await vm.submit()

        let saved = try #require(verification.stored["me"])
        #expect(saved.status == .pending)
        #expect(saved.pharmacyID == "NMRA-123")
        #expect(!vm.canSubmit)                      // can't apply twice
    }

    @Test func rejectedApplicantCanApplyAgain() async {
        let (vm, verification) = makeSUT(profile: TestData.profile(id: "me"))
        verification.stored["me"] = TestData.application(id: "me", status: .rejected)
        await vm.load()
        fillForm(vm)
        #expect(vm.canSubmit)
    }
}