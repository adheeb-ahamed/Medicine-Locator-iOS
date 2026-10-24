//
//  DataUseView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// Plain-language privacy summary (Figma "Data use" screen).
struct DataUseView: View {
    var body: some View {
        List {
            Section("Stored on our server (Firebase)") {
                row("person.fill.questionmark", "A random anonymous ID — no name or phone number")
                row("pills", "Your requests: medicine name and district only")
                row("mappin.slash", "Never your exact location")
                row("building.2", "Reports and on-site checks, linked to your anonymous ID")
                row("star", "Reputation history (only you can see it)")
                row("envelope", "Your email — only if you chose to add one")
            }
            Section("Stored only on this iPhone") {
                row("clock.arrow.circlepath", "Search history")
                row("tray", "Saved reports for offline use")
                row("lock", "App lock and notification settings")
            }
            Section("Never stored or uploaded") {
                row("camera", "Photos you scan — read on this iPhone, then discarded")
                row("location", "Your GPS position — used on the device for distance checks only")
            }
            Section {
                Text("You can delete your account and everything on this iPhone from Profile → Account.")
                    .font(.footnote)
            }
        }
        .navigationTitle("What we store")
    }

    private func row(_ icon: String, _ text: String) -> some View {
        Label(text, systemImage: icon)
    }
}