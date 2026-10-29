//
//  DeepLink.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  DeepLink.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// Turns links like medicinelocator://requests into an app section.
/// The widget opens these links; the host part is AppSection's rawValue
/// (home, help, map, requests, profile).
enum DeepLink {
    static let scheme = "medicinelocator"

    /// medicinelocator://requests → .requests. Anything else → nil (ignored safely).
    static func section(for url: URL) -> AppSection? {
        guard url.scheme == scheme, let host = url.host() else { return nil }
        return AppSection(rawValue: host)
    }
}