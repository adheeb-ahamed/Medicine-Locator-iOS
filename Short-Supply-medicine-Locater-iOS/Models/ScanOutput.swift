//
//  ScanOutput.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// One line of text Vision found, and how tall it was (0–1 of the image height).
struct RecognizedLine: Equatable, Sendable {
    let text: String
    let height: Double
}

/// Everything Vision found in one photo.
struct ScanOutput: Equatable, Sendable {
    let lines: [RecognizedLine]
    let barcodes: [String]
}

/// What we suggest to the user.
struct ScanSuggestion: Equatable {
    let names: [String]       // best guess first (max 3)
    let strength: String?     // e.g. "400 mg"
    let barcode: String?
}
