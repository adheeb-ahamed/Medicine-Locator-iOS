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

    func makeSourcesViewModel(_ scope: SourcesViewModel.Scope) -> SourcesViewModel {
        SourcesViewModel(scope: scope, responseService: responses, pharmacyService: pharmacies)
    }

    func makeNewRequestViewModel(medicineName: String = "") -> NewRequestViewModel {
        NewRequestViewModel(medicineName: medicineName,
                            requestService: requests,
                            pharmacyService: pharmacies,
                            locationService: location,
                            authService: auth)
    }

    func makeMyRequestsViewModel() -> MyRequestsViewModel {
        MyRequestsViewModel(requestService: requests, authService: auth)
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
}
