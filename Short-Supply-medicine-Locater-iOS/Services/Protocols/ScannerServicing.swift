//
//  ScannerServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreGraphics
import ImageIO

@MainActor
protocol ScannerServicing {
    func scan(_ image: CGImage, orientation: CGImagePropertyOrientation) async throws -> ScanOutput
}
