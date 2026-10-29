//
//  SignInView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  SignInView.swift
//  Short-Supply-medicine-Locater-iOS
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
            GradientInfoCard(icon: "person.crop.circle.badge.checkmark",
                             title: "Welcome back",
                             message: "Sign in to bring your reputation to this phone.")
                .cardRow()

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
                NavigationLink("Forgot password?") {
                    ForgotPasswordView(viewModel: viewModel)
                }
                .foregroundStyle(Theme.accent)
            }
        }
        .screenBackground()
        .safeAreaInset(edge: .bottom) {
            BottomBar {
                Button {
                    Task {
                        if await viewModel.signIn() {
                            await app.refreshProfile()
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isWorking { ProgressView().tint(.white) } else { Text("Sign in") }
                }
                .buttonStyle(.primaryPill)
                .disabled(!viewModel.canSignIn)
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