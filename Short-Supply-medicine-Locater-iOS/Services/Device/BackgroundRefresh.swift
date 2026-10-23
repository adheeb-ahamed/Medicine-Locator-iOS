//
//  BackgroundRefresh.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import BackgroundTasks

/// Ask iOS to wake the app every so often to check for new answers.
enum BackgroundRefresh {
    nonisolated static let identifier = "com.ad.MedicineLocator.refresh"

    /// iOS decides the exact time (based on battery, usage…); we only give the earliest.
    nonisolated static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
