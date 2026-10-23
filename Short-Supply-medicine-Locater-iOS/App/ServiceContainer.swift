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
    let requests : RequestServicing
    let responses : ResponseServicing
    let reputation: ReputationServicing

    init(auth: AuthServicing,
         users: UserServicing,
         biometrics: BiometricServicing,
         pharmacies: PharmacyServicing,
         location: LocationServicing,
         searchHistory: SearchHistoryServicing,
         requests : RequestServicing,
         responses : ResponseServicing,
         reputation : ReputationServicing) {
        self.auth = auth
        self.users = users
        self.biometrics = biometrics
        self.pharmacies = pharmacies
        self.location = location
        self.searchHistory = searchHistory
        self.requests = requests
        self.responses = responses
        self.reputation = reputation
    }

    /// The real services used when the app runs.
    static func live(context: NSManagedObjectContext) -> ServiceContainer {
        ServiceContainer(
            auth: FirebaseAuthService(),
            users: FirestoreUserService(),
            biometrics: BiometricService(),
            pharmacies: PharmacyService(context: context),
            location: LocationService(),
            searchHistory: CoreDataSearchHistoryService(context: context),
            requests: FirestoreRequestService(),
            responses: FirestoreResponseService(),
            reputation: FirestoreReputationService()
        )
    }
}
