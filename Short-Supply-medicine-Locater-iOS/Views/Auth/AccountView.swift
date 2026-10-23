//
//  AccountView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI

struct AccountView: View {
    @Environment(AppViewModel.self) private var app
    @State private var activeSheet: AuthSheet?
    @State private var signOutError: String?
    @Environment(ServiceContainer.self) private var services
    @State private var reputation: Int?

    enum AuthSheet: Identifiable {
        case signIn, createAccount
        var id: Self { self }
    }

    var body: some View {
        @Bindable var app = app

        List {
            Section {
                LabeledContent("Role", value: app.profile?.role.displayName ?? "—")
                LabeledContent("Reputation", value: reputation.map(String.init) ?? "…")
                LabeledContent("Status", value: app.isAnonymous ? "Anonymous" : "Signed in")
            }

            Section {
                Toggle("Lock with Face ID", isOn: $app.isAppLockEnabled)
                    .disabled(!app.isBiometricAvailable)
            } header: {
                Text("Security")
            } footer: {
                Text(app.isBiometricAvailable
                     ? "The app locks whenever you leave it."
                     : "Set up Face ID or a passcode in Settings to use app lock.")
            }

            Section("Account") {
                if app.isAnonymous {
                    Text("You can request and help without an account. Add an email to keep your reputation if you change phones.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Save my reputation") { activeSheet = .createAccount }
                    Button("I already have an account") { activeSheet = .signIn }
                } else {
                    LabeledContent("Email", value: app.profile?.email ?? "—")
                    Button("Sign out", role: .destructive) {
                        Task {
                            do { try await app.signOut() }
                            catch { signOutError = error.localizedDescription }
                        }
                    }
                }
            }
        }
        .navigationTitle("Account")
        .task {
            guard let userID = app.authService.currentUserID,
                  let entries = try? await services.reputation.entries(for: userID) else { return }
            reputation = ReputationPolicy.total(of: entries)
        }
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
        .alert("Couldn't sign out",
               isPresented: Binding(get: { signOutError != nil },
                                    set: { if !$0 { signOutError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(signOutError ?? "")
        }
    }
}
