//
//  FindMedicineIntent.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  MedicineLocatorIntents.swift
//  Short-Supply-medicine-Locater-iOS
//

import AppIntents

/// "Find a medicine" — Siri asks which one, then the app opens on the results.
struct FindMedicineIntent: AppIntent {
    static let title: LocalizedStringResource = "Find a Medicine"
    static let description = IntentDescription("Search licensed pharmacies for a medicine.")
    static let openAppWhenRun = true      // results are shown inside the app

    // If the user didn't say a name, Siri asks this question.
    @Parameter(title: "Medicine", requestValueDialog: "Which medicine are you looking for?")
    var medicine: String

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentRouter.shared.openSearch(for: medicine)
        return .result()
    }
}

/// "Check my requests" — Siri answers WITHOUT opening the app.
struct CheckMyRequestsIntent: AppIntent {
    static let title: LocalizedStringResource = "Check My Requests"
    static let description = IntentDescription("Hear how many requests are open and how many answers they have.")

    // The phone must be unlocked — a locked phone shouldn't reveal health requests.
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Uses the SAME discreet setting as notifications (on by default).
        let discreet = NotificationPreferences.load(from: .standard).discreet

        guard let summary = RequestsSummaryStore().load() else {
            return .result(dialog: "\(RequestsSummary.noDataText)")
        }
        return .result(dialog: "\(summary.spokenText(discreet: discreet))")
    }
}

/// "Open my requests" — jumps straight to the My Requests tab.
struct OpenMyRequestsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open My Requests"
    static let description = IntentDescription("Opens the list of medicines you asked for.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentRouter.shared.open(.requests)
        return .result()
    }
}