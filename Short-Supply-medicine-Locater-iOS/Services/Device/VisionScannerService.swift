//
//  VisionScannerService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Vision
import CoreGraphics
import ImageIO

/// On-device text + barcode recognition with Apple's Vision framework.
@MainActor
final class VisionScannerService: ScannerServicing {

    func scan(_ image: CGImage, orientation: CGImagePropertyOrientation) async throws -> ScanOutput {
        // Vision is slow (100s of ms) — run it OFF the main thread so the UI doesn't freeze.
        try await Task.detached(priority: .userInitiated) {
            try VisionScannerService.performScan(image, orientation: orientation)
        }.value
    }

    nonisolated private static func performScan(_ image: CGImage,
                                                orientation: CGImagePropertyOrientation) throws -> ScanOutput {
        // 1. Text recognition
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate        // slower but better for small print
        textRequest.usesLanguageCorrection = false      // "Imatinib" isn't a dictionary word

        // 2. Barcode detection
        let barcodeRequest = VNDetectBarcodesRequest()

        #if targetEnvironment(simulator)
        // The simulator has no Neural Engine; force the CPU so Vision doesn't fail.
        textRequest.usesCPUOnly = true
        barcodeRequest.usesCPUOnly = true
        #endif

        // 3. Run both requests on the same image in one pass
        let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        try handler.perform([textRequest, barcodeRequest])

        // 4. Convert Vision's results into our plain model
        let lines: [RecognizedLine] = (textRequest.results ?? []).compactMap { observation in
            guard let best = observation.topCandidates(1).first else { return nil }
            return RecognizedLine(text: best.string, height: Double(observation.boundingBox.height))
        }
        let barcodes = (barcodeRequest.results ?? []).compactMap(\.payloadStringValue)

        return ScanOutput(lines: lines, barcodes: barcodes)
    }
}
