//
//  ScanParserTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
@testable import Short_Supply_medicine_Locater_iOS

struct ScanParserTests {

    /// What Vision might read from a typical box (heights are made up but realistic).
    let box = [
        RecognizedLine(text: "Batch No: B1234", height: 0.02),
        RecognizedLine(text: "Imatinib Tablets 400 mg", height: 0.06),
        RecognizedLine(text: "GLIVEC", height: 0.12),
        RecognizedLine(text: "Exp: 12/2027", height: 0.02),
        RecognizedLine(text: "Film-coated tablets", height: 0.03)
    ]

    @Test func biggestTextComesFirst() {
        let result = ScanParser.suggestion(from: box, barcodes: [])
        #expect(result.names == ["Glivec", "Imatinib"])
    }

    @Test func findsTheStrength() {
        let result = ScanParser.suggestion(from: box, barcodes: [])
        #expect(result.strength == "400 mg")
    }

    @Test(arguments: zip(["400mg", "400 MG", "0.5 mcg", "10ml"],
                         ["400 mg", "400 mg", "0.5 mcg", "10 ml"]))
    func strengthIsNormalised(text: String, expected: String) {
        #expect(ScanParser.strength(in: text) == expected)
    }

    @Test(arguments: ["Batch No: B1234", "Exp: 12/2027", "Film-coated tablets", "123456", "Rx only"])
    func packagingLinesAreNotNames(line: String) {
        #expect(ScanParser.cleanName(line) == nil)
    }

    @Test func duplicatesAreRemoved() {
        let lines = [RecognizedLine(text: "IMATINIB", height: 0.1),
                     RecognizedLine(text: "Imatinib", height: 0.05)]
        #expect(ScanParser.suggestion(from: lines, barcodes: []).names == ["Imatinib"])
    }

    @Test func keepsTheFirstBarcode() {
        let result = ScanParser.suggestion(from: box, barcodes: ["4791234567890"])
        #expect(result.barcode == "4791234567890")
    }

    @Test func nothingReadableGivesNoNames() {
        let lines = [RecognizedLine(text: "12/2027", height: 0.1)]
        #expect(ScanParser.suggestion(from: lines, barcodes: []).names.isEmpty)
    }
}
