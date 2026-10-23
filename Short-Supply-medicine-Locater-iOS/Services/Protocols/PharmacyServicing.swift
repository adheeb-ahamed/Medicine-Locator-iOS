//
//  PharmacyServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Provides the licensed pharmacy list.
@MainActor
protocol PharmacyServicing {
    func loadPharmacies() throws -> [Pharmacy]
}
