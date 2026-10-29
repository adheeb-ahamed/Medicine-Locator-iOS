//
//  CreateAccountView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  CreateAccountView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Links an email to the anonymous account ("Save my reputation").
struct CreateAccountView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            GradientInfoCard(icon: "lock.shield.fill",
                             title: "Save my reputation",
                             message: "Your email is only used to sign in and keep your points. It's never shown to anyone.")
                .cardRow()

            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password (6+ characters)", text: $viewModel.password)
                    .textContentType(.newPassword)
                SecureField("Confirm password", text: $viewModel.confirmPassword)
                    .textContentType(.newPassword)
            }

            if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                Section {
                    Label("Passwords don't match.", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Theme.warning)
                }
                .listRowBackground(Theme.warningTint)
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                Button {
                    Task {
                        if await viewModel.createAccount() {
                            await app.refreshProfile()
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isWorking { ProgressView().tint(.white) } else { Text("Create account") }
                }
                .buttonStyle(.primaryPill)
                .disabled(!viewModel.canCreateAccount)
            }
        }
        .navigationTitle("Save my reputation")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}