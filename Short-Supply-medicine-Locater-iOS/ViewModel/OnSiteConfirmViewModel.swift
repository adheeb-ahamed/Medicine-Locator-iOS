import Foundation
import Observation
import CoreLocation

/// The "Are you at this pharmacy?" voting box on a report.
@MainActor
@Observable
final class OnSiteConfirmViewModel {
    enum State: Equatable {
        case checking
        case ownResponse                    // can't vote on your own report
        case alreadyVoted
        case locationOff
        case tooFar(distance: Double)       // further than 100 m
        case ready(distance: Double)        // inside 100 m — show the 3 buttons
        case sending
        case done(Confirmation.Verdict)
        case failed(String)
    }

    let response: AvailabilityResponse
    let pharmacy: Pharmacy?
    private(set) var state: State = .checking

    private let responseService: ResponseServicing
    private let locationService: LocationServicing
    private let authService: AuthServicing

    init(response: AvailabilityResponse,
         pharmacy: Pharmacy?,
         responseService: ResponseServicing,
         locationService: LocationServicing,
         authService: AuthServicing) {
        self.response = response
        self.pharmacy = pharmacy
        self.responseService = responseService
        self.locationService = locationService
        self.authService = authService
    }

    func check() async {
        state = .checking
        guard let userID = authService.currentUserID else {
            state = .failed("You're not signed in.")
            return
        }
        guard response.responderID != userID else {
            state = .ownResponse
            return
        }
        guard let pharmacy else {
            state = .failed("This pharmacy isn't in the licensed list.")
            return
        }

        do {
            if try await responseService.hasVoted(on: response.id, userID: userID) {
                state = .alreadyVoted
                return
            }
            let here = try await locationService.currentLocation()
            let distance = pharmacy.distance(from: here)
            state = OnSiteRule.isOnSite(here, at: pharmacy)
                ? .ready(distance: distance)
                : .tooFar(distance: distance)
        } catch LocationError.permissionDenied {
            state = .locationOff
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func vote(_ verdict: Confirmation.Verdict) async {
        // Only vote when we're in the .ready state (whatever the distance).
        guard case .ready = state, let userID = authService.currentUserID else { return }
        state = .sending
        do {
            try await responseService.vote(verdict, on: response, by: userID)
            state = .done(verdict)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
