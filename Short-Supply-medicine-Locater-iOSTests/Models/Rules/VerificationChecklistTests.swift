//
//  VerificationChecklistTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct VerificationChecklistTests {

    @Test(arguments: ["NMRA-123", "nmra 123", "NMRA123", " nmra-123 "])
    func licenceMatchIgnoresCaseSpacesAndDashes(typed: String) {
        let application = TestData.application(licenceNumber: typed)
        #expect(VerificationChecklist.licenceMatches(application))
    }

    @Test func differentLicenceDoesNotMatch() {
        #expect(!VerificationChecklist.licenceMatches(TestData.application(licenceNumber: "NMRA-999")))
    }

    @Test func approveNeedsEveryCheck() {
        let good = TestData.application()
        #expect(!VerificationChecklist.canApprove(good, calledPublicNumber: false))
        #expect(VerificationChecklist.canApprove(good, calledPublicNumber: true))

        let wrongLicence = TestData.application(licenceNumber: "NMRA-999")
        #expect(!VerificationChecklist.canApprove(wrongLicence, calledPublicNumber: true))

        let alreadyDone = TestData.application(status: .approved)
        #expect(!VerificationChecklist.canApprove(alreadyDone, calledPublicNumber: true))
    }
}
