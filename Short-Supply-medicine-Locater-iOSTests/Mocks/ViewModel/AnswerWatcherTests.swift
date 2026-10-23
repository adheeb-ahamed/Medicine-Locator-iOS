//
//  AnswerWatcherTests.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import Testing
import Foundation
import UserNotifications
@testable import Short_Supply_medicine_Locater_iOS

@MainActor
struct AnswerWatcherTests {

    private func makeSUT() -> (AnswerWatcher, MockResponseService, MockNotificationService, UserDefaults) {
        let auth = MockAuthService()
        auth.currentUserID = "anon-user"

        let requests = MockRequestService()
        requests.stored = [TestData.request(id: "request-1")]

        let responses = MockResponseService()
        let notifications = MockNotificationService()
        let defaults = UserDefaults(suiteName: UUID().uuidString)!

        let watcher = AnswerWatcher(requestService: requests,
                                    responseService: responses,
                                    notificationService: notifications,
                                    authService: auth,
                                    defaults: defaults)
        return (watcher, responses, notifications, defaults)
    }

    @Test func firstCheckIsSilentThenNewAnswerNotifiesOnce() async {
        let (watcher, responses, notifications, _) = makeSUT()
        responses.responses = [TestData.response(id: "old", createdAt: .now)]

        await watcher.checkForNewAnswers()                 // first run: remember "old"
        #expect(notifications.sent.isEmpty)

        responses.responses.append(TestData.response(id: "new", createdAt: .now))
        await watcher.checkForNewAnswers()
        #expect(notifications.sent.map(\.id) == ["answer-new"])

        await watcher.checkForNewAnswers()                 
        #expect(notifications.sent.count == 1)
    }

    @Test func discreetByDefault() async {
        let (watcher, responses, notifications, _) = makeSUT()
        await watcher.checkForNewAnswers()                 // first run
        responses.responses = [TestData.response(id: "new", createdAt: .now)]
        await watcher.checkForNewAnswers()
        #expect(!notifications.sent[0].title.contains("Imatinib"))
    }

    @Test func noPermissionMeansNoNotifications() async {
        let (watcher, responses, notifications, _) = makeSUT()
        notifications.status = .denied
        await watcher.checkForNewAnswers()
        responses.responses = [TestData.response(id: "new", createdAt: .now)]
        await watcher.checkForNewAnswers()
        #expect(notifications.sent.isEmpty)
    }

    @Test func turnedOffInSettingsMeansNoNotifications() async {
        let (watcher, responses, notifications, defaults) = makeSUT()
        var preferences = NotificationPreferences()
        preferences.answers = false
        preferences.save(to: defaults)

        await watcher.checkForNewAnswers()
        responses.responses = [TestData.response(id: "new", createdAt: .now)]
        await watcher.checkForNewAnswers()
        #expect(notifications.sent.isEmpty)
    }
}
