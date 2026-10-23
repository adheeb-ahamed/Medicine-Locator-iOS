//
//  MedicinePolicyTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct MedicinePolicyTests {

    @Test(arguments: ["Morphine", "morphine sulfate", "  TRAMADOL  ", "Diazepam 5 mg"])
    func controlledMedicinesAreBlocked(name: String) {
        #expect(MedicinePolicy.isControlled(name))
    }

    @Test(arguments: ["Imatinib", "Tamoxifen", "Insulin glargine"])
    func normalMedicinesAreAllowed(name: String) {
        #expect(!MedicinePolicy.isControlled(name))
    }

    @Test func keyIgnoresSpacesAndCase() {
        #expect(Medicine.key(for: "  Imatinib ") == "imatinib")
    }
}
