//
//  ForgotPasswordView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

struct ForgotPasswordView: View {
    /// Borrowed from SignInView, so the email typed there is already filled in.
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } footer: {
                Text("We'll email you a link to reset your password.")
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)

            Section {
                Button {
                    Task { await viewModel.resetPassword() }
                } label: {
                    if viewModel.isWorking { ProgressView() } else { Text("Send reset link") }
                }
                .disabled(!viewModel.isValidEmail || viewModel.isWorking)
            }
        }
        .navigationTitle("Reset password")
    }
}
