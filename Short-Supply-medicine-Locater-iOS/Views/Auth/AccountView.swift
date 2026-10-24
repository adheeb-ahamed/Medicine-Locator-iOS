//
//  AccountView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

/// Account: save reputation, sign in/out, delete account.
struct AccountView: View {
    @Environment(AppViewModel.self) private var app
    @State private var viewModel: AccountViewModel
    @State private var activeSheet: AuthSheet?
    @State private var confirmDelete = false
    @State private var signOutError: String?

    enum AuthSheet: Identifiable {
        case signIn, createAccount
        var id: Self { self }
    }

    init(viewModel: AccountViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                if app.isAnonymous {
                    Text("You can request and help without an account. Add an email to keep your reputation if you change phones.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Save my reputation") { activeSheet = .createAccount }
                    Button("I already have an account") { activeSheet = .signIn }
                } else {
                    LabeledContent("Email", value: app.profile?.email ?? "—")
                    Button("Sign out") {
                        Task {
                            do { try await app.signOut() }
                            catch { signOutError = error.localizedDescription }
                        }
                    }
                }
            } header: {
                Text("Account")
            }

            Section {
                Button("Delete my account", role: .destructive) { confirmDelete = true }
                    .disabled(viewModel.isWorking)
                if viewModel.isWorking { ProgressView() }
                if let error = viewModel.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(Theme.danger)
                }
            } footer: {
                Text("Deletes your profile, sign-in, search history and saved reports. Your past requests and reports stay anonymous and expire on their own.")
            }
        }
        .navigationTitle("Account")
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .signIn:
                    SignInView(viewModel: AuthViewModel(authService: app.authService))
                case .createAccount:
                    CreateAccountView(viewModel: AuthViewModel(authService: app.authService))
                }
            }
        }
        .confirmationDialog("Delete your account?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete account", role: .destructive) {
                Task {
                    if await viewModel.deleteAccount() {
                        app.resetAfterAccountDeletion()
                    }
                }
            }
        } message: {
            Text("This can't be undone. Your reputation will be lost.")
        }
        .alert("Couldn't sign out",
               isPresented: Binding(get: { signOutError != nil },
                                    set: { if !$0 { signOutError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(signOutError ?? "")
        }
    }
}
