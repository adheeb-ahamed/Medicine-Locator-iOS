//
//  ServiceContainer + Factories.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation

/// Factory methods: one place that knows how to build each ViewModel.
extension ServiceContainer {

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(historyService: searchHistory) { [unowned self] key in
            self.makeSourcesViewModel(.medicine(key: key))
        }
    }


    func makeNewRequestViewModel(medicineName: String = "") -> NewRequestViewModel {
        NewRequestViewModel(medicineName: medicineName,
                            requestService: requests,
                            pharmacyService: pharmacies,
                            locationService: location,
                            authService: auth)
    }

    
    func makeHelpViewModel() -> HelpViewModel {
        HelpViewModel(requestService: requests, locationService: location, authService: auth)
    }

    func makeRespondViewModel(for request: MedicineRequest) -> RespondViewModel {
        RespondViewModel(request: request,
                         responseService: responses,
                         pharmacyService: pharmacies,
                         locationService: location,
                         authService: auth)
    }

    func makeOnSiteConfirmViewModel(response: AvailabilityResponse,
                                    pharmacy: Pharmacy?) -> OnSiteConfirmViewModel {
        OnSiteConfirmViewModel(response: response,
                               pharmacy: pharmacy,
                               responseService: responses,
                               locationService: location,
                               authService: auth)
    }
    

    func makeNotificationSettingsViewModel() -> NotificationSettingsViewModel {
        NotificationSettingsViewModel(notificationService: notifications,
                                      locationService: location,
                                      arrivals: arrivals)
    }

    func makeMyRequestsViewModel() -> MyRequestsViewModel {      // REPLACES the Phase 5 version
        MyRequestsViewModel(requestService: requests,
                            authService: auth,
                            notificationService: notifications)
    }
    
    func makeScanViewModel() -> ScanViewModel {
            ScanViewModel(scanner: scanner)
    }
    

    func makeVerifyPharmacyViewModel(profile: UserProfile) -> VerifyPharmacyViewModel {
        VerifyPharmacyViewModel(profile: profile,
                                verificationService: verification,
                                pharmacyService: pharmacies)
    }

    func makeModeratorViewModel(moderatorID: String) -> ModeratorViewModel {
        ModeratorViewModel(moderatorID: moderatorID,
                           verificationService: verification,
                           pharmacyService: pharmacies)
    }

    func makePharmacyDashboardViewModel(profile: UserProfile) -> PharmacyDashboardViewModel {
        PharmacyDashboardViewModel(profile: profile,
                                   responseService: responses,
                                   pharmacyService: pharmacies)
    }
    
    func makeSourcesViewModel(_ scope: SourcesViewModel.Scope) -> SourcesViewModel {   // REPLACES old one
        SourcesViewModel(scope: scope,
                         responseService: responses,
                         pharmacyService: pharmacies,
                         connectivity: connectivity,
                         cache: sourceCache)
    }



    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(reputationService: reputation, authService: auth)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(searchHistory: searchHistory, sourceCache: sourceCache, connectivity: connectivity)
    }

    func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(authService: auth, userService: users,
                         searchHistory: searchHistory, sourceCache: sourceCache)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
            HomeViewModel(pharmacyService: pharmacies, locationService: location)
    }

    func makeMapViewModel() -> MapViewModel {
        MapViewModel(pharmacyService: pharmacies)
    }
}
