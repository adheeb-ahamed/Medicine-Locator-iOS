//
//  Short_Supply_medicine_Locater_iOSApp.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import SwiftUI
import FirebaseCore
import CoreData

@main
struct Short_Supply_medicine_Locater_iOSApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SetupCheckView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
    }
}
