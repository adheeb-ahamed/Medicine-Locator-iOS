//
//  MockScannerService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreGraphics
import ImageIO
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
final class MockScannerService: ScannerServicing {
    var output = ScanOutput(lines: [], barcodes: [])
    var error: Error?

    func scan(_ image: CGImage, orientation: CGImagePropertyOrientation) async throws -> ScanOutput {
        if let error { throw error }
        return output
    }
}
