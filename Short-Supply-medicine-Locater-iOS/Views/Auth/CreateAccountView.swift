//
//  CreateAccountView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
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
            } footer: {
                Text("Your email is only used to sign in and keep your reputation. It's never shown to anyone.")
            }

            if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                Section {
                    Text("Passwords don't match.").foregroundStyle(Theme.warning)
                }
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)

            Section {
                Button {
                    Task {
                        if await viewModel.createAccount() {
                            await app.refreshProfile()
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isWorking { ProgressView() } else { Text("Create account") }
                }
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
