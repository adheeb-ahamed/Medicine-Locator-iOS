//
//  ConnectivityServicing.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Are we online? `simulateOffline` lets you demo offline mode without turning off Wi-Fi.
@MainActor
protocol ConnectivityServicing: AnyObject {
    var isOnline: Bool { get }
    var simulateOffline: Bool { get set }
}
