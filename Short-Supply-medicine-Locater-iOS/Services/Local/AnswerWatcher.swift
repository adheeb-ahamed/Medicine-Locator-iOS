//
//  AnswerWatcher.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import UserNotifications

/// Checks my open requests for new answers and posts local notifications.
@MainActor
final class AnswerWatcher {
    private static let seenKey = "seenResponseIDs"
    private var isChecking = false

    private let requestService: RequestServicing
    private let responseService: ResponseServicing
    private let notificationService: NotificationServicing
    private let authService: AuthServicing
    private let defaults: UserDefaults

    init(requestService: RequestServicing,
         responseService: ResponseServicing,
         notificationService: NotificationServicing,
         authService: AuthServicing,
         defaults: UserDefaults = .standard) {
        self.requestService = requestService
        self.responseService = responseService
        self.notificationService = notificationService
        self.authService = authService
        self.defaults = defaults
    }

    func checkForNewAnswers() async {
        guard !isChecking else { return }            // don't run two checks at once
        isChecking = true
        defer { isChecking = false }

        let preferences = NotificationPreferences.load(from: defaults)
        guard preferences.answers,
              await notificationService.authorizationStatus() == .authorized,
              let ownerID = authService.currentUserID,
              let myRequests = try? await requestService.requests(ownedBy: ownerID) else { return }

        // All answers to my OPEN requests
        var answers: [AvailabilityResponse] = []
        for request in myRequests where request.effectiveStatus() == .open {
            if let found = try? await responseService.responses(forRequestID: request.id) {
                answers += found
            }
        }

        // What's new since last time?
        let seen = defaults.stringArray(forKey: Self.seenKey).map(Set.init)
        let diff = AnswerDiff.compare(current: answers, seen: seen)

        for answer in diff.toNotify {
            let text = NotificationText.newAnswer(medicineName: answer.medicineName,
                                                  pharmacyName: answer.pharmacyName,
                                                  discreet: preferences.discreet)
            await notificationService.notify(id: "answer-\(answer.id)", title: text.title, body: text.body)
        }

        defaults.set(Array(diff.updatedSeen), forKey: Self.seenKey)
    }
}
