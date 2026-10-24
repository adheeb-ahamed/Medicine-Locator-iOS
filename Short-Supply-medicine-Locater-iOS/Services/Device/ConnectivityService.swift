//
//  ConnectivityService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import Network
import Observation

/// Watches the network with NWPathMonitor. Screens update automatically (@Observable).
@MainActor
@Observable
final class ConnectivityService: ConnectivityServicing {
    private(set) var isNetworkAvailable = true
    var simulateOffline = false

    var isOnline: Bool { isNetworkAvailable && !simulateOffline }

    @ObservationIgnored private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let available = path.status == .satisfied
            // NWPathMonitor calls back on its own queue — hop to the main actor to update the UI.
            Task { @MainActor in
                self?.isNetworkAvailable = available
            }
        }
        monitor.start(queue: DispatchQueue(label: "ConnectivityMonitor"))
    }
}
