//
//  ScanViewModelTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Testing
import Foundation
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct ScanViewModelTests {

    @Test func readableBoxGivesSuggestions() async {
        let scanner = MockScannerService()
        scanner.output = ScanOutput(lines: [RecognizedLine(text: "Imatinib 400 mg", height: 0.1)],
                                    barcodes: [])
        let vm = ScanViewModel(scanner: scanner)

        await vm.scan(TestData.blankImage)

        #expect(vm.state == .found(ScanSuggestion(names: ["Imatinib"], strength: "400 mg", barcode: nil)))
    }

    @Test func unreadablePhotoFails() async {
        let scanner = MockScannerService()
        scanner.output = ScanOutput(lines: [RecognizedLine(text: "12/2027", height: 0.1)], barcodes: [])
        let vm = ScanViewModel(scanner: scanner)

        await vm.scan(TestData.blankImage)

        if case .failed = vm.state { } else { Issue.record("Expected failed, got \(vm.state)") }
    }

    @Test func visionErrorFails() async {
        let scanner = MockScannerService()
        scanner.error = URLError(.unknown)
        let vm = ScanViewModel(scanner: scanner)

        await vm.scan(TestData.blankImage)

        if case .failed = vm.state { } else { Issue.record("Expected failed, got \(vm.state)") }
    }
}
