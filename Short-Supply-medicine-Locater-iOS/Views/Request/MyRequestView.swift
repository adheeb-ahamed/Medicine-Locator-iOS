//
//  MyRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// The watchlist tab (MVP item 9).
struct MyRequestsView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: MyRequestsViewModel
    @State private var showingNewRequest = false

    init(viewModel: MyRequestsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if viewModel.showNotificationNudge {
                Section {
                    PermissionPromptView(
                        icon: "bell.badge",
                        title: "Get notified when someone answers",
                        message: "Notifications are discreet by default — no medicine names on your lock screen.",
                        buttonTitle: "Turn on notifications") {
                            Task { await viewModel.enableNotifications() }
                        }
                }
            }
            if !viewModel.active.isEmpty {
                Section("Looking for") {
                    ForEach(viewModel.active) { row(for: $0) }
                }
            }
            if !viewModel.past.isEmpty {
                Section("Past") {
                    ForEach(viewModel.past) { row(for: $0) }
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
            }
        }
        .overlay {
            if viewModel.requests.isEmpty && !viewModel.isLoading {
                ContentUnavailableView {
                    Label("No requests yet", systemImage: "tray")
                } description: {
                    Text("Ask people nearby to look for a medicine for you.")
                } actions: {
                    Button("New request") { showingNewRequest = true }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent)
                }
            }
        }
        .navigationTitle("My Requests")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingNewRequest = true } label: {
                    Label("New request", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewRequest, onDismiss: {
            Task { await viewModel.load() }
        }) {
            NavigationStack {
                NewRequestView(viewModel: services.makeNewRequestViewModel())
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func row(for request: MedicineRequest) -> some View {
        NavigationLink {
            RequestDetailView(request: request,
                              myRequests: viewModel,
                              sources: services.makeSourcesViewModel(.request(id: request.id)))
        } label: {
            RequestRow(request: request)
        }
    }
}
