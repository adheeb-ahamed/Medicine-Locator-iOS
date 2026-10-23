//
//  ScanViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Observation
import CoreGraphics
import ImageIO

/// Scan screen: idle → scanning → found suggestions / failed.
@MainActor
@Observable
final class ScanViewModel {
    enum State: Equatable {
        case idle
        case scanning
        case found(ScanSuggestion)
        case failed(String)
    }

    private(set) var state: State = .idle
    private let scanner: ScannerServicing

    init(scanner: ScannerServicing) {
        self.scanner = scanner
    }

    func scan(_ image: CGImage, orientation: CGImagePropertyOrientation = .up) async {
        state = .scanning
        do {
            let output = try await scanner.scan(image, orientation: orientation)
            let suggestion = ScanParser.suggestion(from: output.lines, barcodes: output.barcodes)
            state = suggestion.names.isEmpty
                ? .failed("We couldn't read a medicine name. Try a clearer, well-lit photo of the front of the box.")
                : .found(suggestion)
        } catch {
            state = .failed("Scanning failed: \(error.localizedDescription)")
        }
    }

    func reset() {
        state = .idle
    }
}
