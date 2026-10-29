//
//  MyRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  MyRequestView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// The watchlist tab (MVP item 9) — summary tiles + request cards.
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
                PermissionPromptView(
                    icon: "bell.badge.fill",
                    title: "Get notified when someone answers",
                    message: "Notifications are discreet by default — no medicine names on your lock screen.",
                    buttonTitle: "Turn on notifications") {
                        Task { await viewModel.enableNotifications() }
                    }
                    .cardStyle()
                    .cardRow()
            }

            if !viewModel.active.isEmpty {
                HStack(spacing: 12) {
                    StatTile(value: "\(viewModel.active.count)", label: "looking for",
                             systemImage: "magnifyingglass", style: .card)
                    StatTile(value: "\(viewModel.activeAnswerCount)", label: "answers so far",
                             systemImage: "bubble.left.and.bubble.right.fill", style: .card)
                }
                .cardRow()

                Section {
                    ForEach(viewModel.active) { row(for: $0) }
                } header: {
                    sectionHeader("Looking for")
                }
            }

            if !viewModel.past.isEmpty {
                Section {
                    ForEach(viewModel.past) { row(for: $0) }
                } header: {
                    sectionHeader("Past")
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
                    .cardRow()
            }
        }
        .screenBackground()
        .overlay {
            if viewModel.requests.isEmpty && !viewModel.isLoading {
                ContentUnavailableView {
                    Label("No requests yet", systemImage: "tray")
                } description: {
                    Text("Ask people nearby to look for a medicine for you.")
                } actions: {
                    Button {
                        showingNewRequest = true
                    } label: {
                        Label("New request", systemImage: "plus")
                    }
                    .buttonStyle(.primaryPill)
                    .frame(width: 240)
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.sectionTitle)
            .accessibilityAddTraits(.isHeader)
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    private func row(for request: MedicineRequest) -> some View {
        NavigationLink {
            RequestDetailView(request: request,
                              myRequests: viewModel,
                              sources: services.makeSourcesViewModel(
                                  .request(id: request.id, medicineKey: request.medicine.key)))
        } label: {
            RequestRow(request: request)
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .cardRow()
    }
}
