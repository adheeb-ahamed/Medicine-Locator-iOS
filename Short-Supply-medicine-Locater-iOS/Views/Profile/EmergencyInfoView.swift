//
//  EmergencyInfoView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

/// Emergency disclaimer (Figma "Emergency info" screen).
struct EmergencyInfoView: View {
    var body: some View {
        List {
            Section {
                Label("This app is not for emergencies.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(Theme.danger)
                    .font(.headline)
                Text("Reports come from members of the public and can be wrong or out of date. Always call the pharmacy before travelling.")
            }
            Section("If someone is in danger") {
                if let url = URL(string: "tel:1990") {
                    Link(destination: url) {
                        Label("Call 1990 — Suwa Seriya ambulance", systemImage: "phone.fill")
                    }
                }
                Text("Or go to the nearest hospital emergency unit.")
            }
            Section("About medicines") {
                Text("Never take a medicine that wasn't prescribed for you. Ask your doctor or pharmacist about alternatives if a medicine is out of stock.")
            }
        }
        .screenBackground()
        .navigationTitle("Emergency help")
    }
}