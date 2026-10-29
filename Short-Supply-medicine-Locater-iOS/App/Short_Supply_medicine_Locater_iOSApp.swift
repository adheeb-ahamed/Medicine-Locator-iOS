//
//  Short_Supply_medicine_Locater_iOSApp.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-17.
//

import SwiftUI
import CoreData
import FirebaseCore
import BackgroundTasks

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
                .preferredColorScheme(.light)   // redesign is light-only; colours were contrast-checked for light
                .environment(appViewModel)
        }
        .preferredColorScheme(.light)   // redesign is light-only; colours were contrast-checked for light
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                Task { await services.appDidBecomeActive() }    // check answers + resume arrivals
            case .background:
                appViewModel.lock()                             // Phase 2
                BackgroundRefresh.schedule()                    // ask iOS to wake us later
            default:
                break
            }
        }
        .backgroundTask(.appRefresh(BackgroundRefresh.identifier)) { [services] in
            BackgroundRefresh.schedule()                        // keep the chain going
            await services.answerWatcher.checkForNewAnswers()
        }
    }
}
