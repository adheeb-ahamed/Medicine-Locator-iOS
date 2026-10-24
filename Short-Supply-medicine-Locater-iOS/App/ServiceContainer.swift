//
//  ServiceContainer.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation
import CoreData

/// Holds one instance of every service. Created once in the @main file.
@MainActor
@Observable
final class ServiceContainer {
    let auth: AuthServicing
    let users: UserServicing
    let biometrics: BiometricServicing
    let pharmacies: PharmacyServicing
    let location: LocationServicing
    let searchHistory: SearchHistoryServicing
    let requests: RequestServicing
    let responses: ResponseServicing
    let reputation: ReputationServicing
    let notifications: NotificationServicing
    let answerWatcher: AnswerWatcher
    let arrivals: ArrivalMonitoring
    let scanner : ScannerServicing
    let verification : VerificationServicing

    init(auth: AuthServicing,
         users: UserServicing,
         biometrics: BiometricServicing,
         pharmacies: PharmacyServicing,
         location: LocationServicing,
         searchHistory: SearchHistoryServicing,
         requests: RequestServicing,
         responses: ResponseServicing,
         reputation: ReputationServicing,
         notifications: NotificationServicing,
         answerWatcher: AnswerWatcher,
         arrivals: ArrivalMonitoring,
         scanner:ScannerServicing,
         verification:VerificationServicing) {
        self.auth = auth
        self.users = users
        self.biometrics = biometrics
        self.pharmacies = pharmacies
        self.location = location
        self.searchHistory = searchHistory
        self.requests = requests
        self.responses = responses
        self.reputation = reputation
        self.notifications = notifications
        self.answerWatcher = answerWatcher
        self.arrivals = arrivals
        self.scanner = scanner
        self.verification = verification
    }

    /// The real services used when the app runs.
    static func live(context: NSManagedObjectContext) -> ServiceContainer {
        // Services that others depend on are created first.
        let auth = FirebaseAuthService()
        let pharmacies = PharmacyService(context: context)
        let location = LocationService()
        let requests = FirestoreRequestService()
        let responses = FirestoreResponseService()
        let notifications = NotificationService()
        

        return ServiceContainer(
            auth: auth,
            users: FirestoreUserService(),
            biometrics: BiometricService(),
            pharmacies: pharmacies,
            location: location,
            searchHistory: CoreDataSearchHistoryService(context: context),
            requests: requests,
            responses: responses,
            reputation: FirestoreReputationService(),
            notifications: notifications,
            answerWatcher: AnswerWatcher(requestService: requests,
                                         responseService: responses,
                                         notificationService: notifications,
                                         authService: auth),
            arrivals: RegionMonitorService(pharmacyService: pharmacies,
                                           locationService: location,
                                           notificationService: notifications),
            scanner : VisionScannerService(),
            verification: FirestoreVerificationService()
        )
    }

    /// Called every time the app comes to the front.
    func appDidBecomeActive() async {
        await answerWatcher.checkForNewAnswers()
        await arrivals.resumeIfEnabled()
    }
}
