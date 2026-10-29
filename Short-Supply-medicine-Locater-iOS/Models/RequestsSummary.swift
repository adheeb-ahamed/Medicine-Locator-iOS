//
//  RequestsSummary.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  RequestsSummary.swift
//  Short-Supply-medicine-Locater-iOS
//

import Foundation

/// A tiny saved summary of my OPEN requests.
/// Siri reads it (Phase 13) and the widget will show it (Phase 14),
/// so neither has to sign in to Firebase or download anything.
struct RequestsSummary: Codable, Equatable {
    var activeCount: Int          // how many requests are still open
    var answerCount: Int          // total answers on those requests
    var medicineNames: [String]   // e.g. ["Imatinib 400 mg"]
    var updatedAt: Date           // when this was saved

    /// Same numbers and names? (ignores updatedAt)
    /// Used so we only refresh the widget when something really changed —
    /// iOS limits how often a widget can be refreshed.
    func hasSameContent(as other: RequestsSummary?) -> Bool {
        guard let other else { return false }      // nothing saved before → it changed
        return activeCount == other.activeCount
            && answerCount == other.answerCount
            && medicineNames == other.medicineNames
    }

    /// The sentence Siri says.
    /// discreet = true → never say medicine names out loud (someone nearby could hear
    /// and learn about a health condition). Same setting as the notifications.
    func spokenText(discreet: Bool) -> String {
        guard activeCount > 0 else { return "You have no open requests." }

        let requests = activeCount == 1 ? "1 open request" : "\(activeCount) open requests"
        let answers  = answerCount == 1 ? "1 answer" : "\(answerCount) answers"
        var text = "You have \(requests) with \(answers)."

        if !discreet {
            text += " Looking for: \(medicineNames.joined(separator: ", "))."
        }
        return text
    }

    /// Said when the app has never saved a summary yet (fresh install).
    static let noDataText = "Open Medicine Locator once so I can check your requests."
}
