//
//  NotificationSettingView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: NotificationSettingsViewModel

    init(viewModel: NotificationSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            // 1. System permission
            Section {
                switch viewModel.notificationStatus {
                case .notDetermined:
                    PermissionPromptView(
                        icon: "bell.badge",
                        title: "Know when someone answers",
                        message: "We only notify you about your own requests and, if you choose, when you arrive at a pharmacy.",
                        buttonTitle: "Turn on notifications") {
                            Task { await viewModel.enableNotifications() }
                        }
                case .denied:
                    Text("Notifications are off for Medicine Locator.")
                        .foregroundStyle(.secondary)
                    Button("Open Settings", action: openSettings)
                default:
                    Label("Notifications are on", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Theme.success)
                }
            }

            // 2. What to notify about
            Section("Notify me about") {
                Toggle("New answers to my requests", isOn: $viewModel.preferences.answers)
                Toggle("Arriving at a pharmacy", isOn: $viewModel.preferences.arrivals)
            }
            .disabled(!viewModel.notificationsAllowed)

            // 3. Arrival prompts need "Always" location
            if viewModel.preferences.arrivals && !viewModel.hasAlwaysLocation {
                Section {
                    Text("Arrival prompts need location set to \"Always\" so iOS can tell us when you reach a pharmacy, even when the app is closed.")
                        .font(.footnote)
                    Button("Allow location Always") { viewModel.requestAlwaysLocation() }
                    Button("Open Settings", action: openSettings)
                }
            }

            // 4. Privacy
            Section {
                Toggle("Discreet notifications", isOn: $viewModel.preferences.discreet)
            } footer: {
                Text("Hides medicine and pharmacy names on your lock screen.")
            }
        }
        .screenBackground()
        .navigationTitle("Notifications")
        .task { await viewModel.refresh() }
        .onChange(of: scenePhase) { _, phase in
            // Coming back from the Settings app or a permission popup? Re-check.
            if phase == .active { Task { await viewModel.refresh() } }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
    }
}
