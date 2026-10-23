//
//  NotificationText.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// The words in each notification. Discreet = nothing sensitive on the lock screen.
enum NotificationText {

    static func newAnswer(medicineName: String,
                          pharmacyName: String,
                          discreet: Bool) -> (title: String, body: String) {
        if discreet {
            return ("Medicine Locator", "You have a new answer to your request.")
        }
        return ("New answer: \(medicineName)", "Someone reported it at \(pharmacyName).")
    }

    static func arrival(pharmacyName: String, discreet: Bool) -> (title: String, body: String) {
        if discreet {
            return ("Medicine Locator", "You're near a pharmacy. Can you help someone nearby?")
        }
        return ("You're at \(pharmacyName)", "Can you confirm stock for people nearby?")
    }
}
