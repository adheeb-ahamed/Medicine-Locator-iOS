//
//  SettingsView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//


import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: SettingsViewModel
    @State private var confirmClear = false
    @AppStorage(AppearanceMode.storageKey) private var appearance: AppearanceMode = .system
    @AppStorage(TextSizeMode.storageKey) private var textSize: TextSizeMode = .system
    @AppStorage(AccessibilitySettings.reduceMotionKey) private var reduceMotion = false
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverOn   // read-only: is VoiceOver running?

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var app = app

        List {
            Section {
                AppearancePicker(selection: $appearance)
            } header: {
                Text("Appearance")
            } footer: {
                Text("System follows your iPhone's Light/Dark setting.")
            }
            
            Section {
                // Text size (from TextSizeMode)
                Picker("Text size", selection: $textSize) {
                    ForEach(TextSizeMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }

                // Our own switch — adds to the iPhone's Reduce Motion
                Toggle("Reduce motion", isOn: $reduceMotion)

                // VoiceOver can't be switched on by an app, so we only show its status
                LabeledContent("VoiceOver", value: voiceOverOn ? "On" : "Off")
            } header: {
                Text("Accessibility")
            } footer: {
                Text("Reduce motion stops ring, pin and confetti animations. VoiceOver is turned on by iOS: Settings → Accessibility → VoiceOver, or triple-click the side button.")
            }
            
            Section {
                Toggle("Lock with Face ID", isOn: $app.isAppLockEnabled)
                    .disabled(!app.isBiometricAvailable)
                NavigationLink {
                    NotificationSettingsView(viewModel: services.makeNotificationSettingsViewModel())
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            } header: {
                Text("Security & alerts")
            } footer: {
                Text(app.isBiometricAvailable
                     ? "The app locks whenever you leave it."
                     : "Set up Face ID or a passcode in iOS Settings to use app lock.")
            }

            Section {
                Button("Clear search history") { viewModel.clearSearchHistory() }
                Button("Clear saved reports", role: .destructive) { confirmClear = true }
            } header: {
                Text("Data on this iPhone")
            } footer: {
                Text("Search history and saved reports are stored only on this iPhone (Core Data) and never uploaded.")
            }

            if let info = viewModel.infoMessage {
                Text(info).font(.footnote).foregroundStyle(Theme.success)
            }

            #if DEBUG
            Section {
                Toggle("Simulate offline", isOn: $viewModel.simulateOffline)
            } header: {
                Text("Developer")
            } footer: {
                Text("Debug builds only — demo offline mode without turning off Wi-Fi.")
            }
            #endif
        }
        .screenBackground()
        .navigationTitle("Settings")
        .confirmationDialog("Clear saved reports?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Clear", role: .destructive) { viewModel.clearSavedReports() }
        } message: {
            Text("You won't see any results while offline until you search again online.")
        }
    }
}
