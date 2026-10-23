//
//  Short_Supply_medicine_Locater_iOSApp.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import SwiftUI
import CoreData
import FirebaseCore

@main
struct Short_Supply_medicine_Locater_iOSApp: App {   // keep YOUR struct name
    let persistenceController = PersistenceController.shared
    @State private var services: ServiceContainer
    @State private var appViewModel: AppViewModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        FirebaseApp.configure()

        // Composition root: the ONLY place real services are created.
        let services = ServiceContainer.live(
            context: PersistenceController.shared.container.viewContext
        )
        _services = State(initialValue: services)
        _appViewModel = State(initialValue: AppViewModel(
            authService: services.auth,
            userService: services.users,
            biometricService: services.biometrics
        ))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appViewModel)
                .environment(services)                       // NEW
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
                .task { await appViewModel.start() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                appViewModel.lock()
            }
        }
    }
}
