//
//  ForgotPasswordView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  ForgotPasswordView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

struct ForgotPasswordView: View {
    /// Borrowed from SignInView, so the email typed there is already filled in.
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        Form {
            GradientInfoCard(icon: "envelope.badge.fill",
                             title: "Reset password",
                             message: "We'll email you a link to reset your password.")
                .cardRow()

            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            MessageSection(error: viewModel.errorMessage, info: viewModel.infoMessage)
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                Button {
                    Task { await viewModel.resetPassword() }
                } label: {
                    if viewModel.isWorking { ProgressView().tint(.white) } else { Text("Send reset link") }
                }
                .buttonStyle(.primaryPill)
                .disabled(!viewModel.isValidEmail || viewModel.isWorking)
            }
        }
        .navigationTitle("Reset password")
    }
}