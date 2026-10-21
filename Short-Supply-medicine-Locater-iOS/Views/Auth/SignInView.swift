//
//  SignInView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

struct SignInView: View {
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
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)

            Section {
                Button {
                    Task {
                        if await viewModel.signIn() {
                            await app.refreshProfile()
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isWorking { ProgressView() } else { Text("Sign in") }
                }
                .disabled(!viewModel.canSignIn)

                NavigationLink("Forgot password?") {
                    ForgotPasswordView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Sign in")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
