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
    @State private var appViewModel: AppViewModel
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // 1. Firebase first — services below need it.
        FirebaseApp.configure()

        // 2. Build the app-wide ViewModel and INJECT the real services.
        _appViewModel = State(initialValue: AppViewModel(
            authService: FirebaseAuthService(),
            userService: FirestoreUserService(),
            biometricService: BiometricService()
        ))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appViewModel)
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
                .task { await appViewModel.start() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Lock again whenever the app goes to the background.
            if newPhase == .background {
                appViewModel.lock()
            }
        }
    }
}
