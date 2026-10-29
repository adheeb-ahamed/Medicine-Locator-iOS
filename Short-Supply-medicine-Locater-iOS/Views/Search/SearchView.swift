//
//  SearchView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  SearchView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// "Find a medicine" — summary card, ranked report cards, recent searches,
/// and a coral "Request this medicine" button pinned to the bottom.
struct SearchView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: SearchViewModel
    @State private var showingNewRequest = false
    @State private var showingScanner = false

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if let submitted = viewModel.submittedQuery, let sources = viewModel.sources {
                MedicineSummaryCard(name: submitted,
                                    resultCount: sources.resultCount,
                                    isLoading: sources.isLoading && !sources.hasLoaded)
                    .cardRow()

                SourcesListView(viewModel: sources,
                                emptyMessage: "No one has reported \(submitted) yet. Ask people nearby to look.")
            }

            if !viewModel.history.isEmpty {
                Section {
                    ForEach(viewModel.history, id: \.self) { item in
                        Button { viewModel.select(item) } label: {
                            Label(item, systemImage: "clock.arrow.circlepath")
                        }
                        .foregroundStyle(.primary)
                    }
                    .onDelete { viewModel.delete(at: $0) }
                } header: {
                    HStack {
                        Text("Recent searches")
                        Spacer()
                        Button("Clear") { viewModel.clearHistory() }.font(.caption)
                    }
                } footer: {
                    Text("Saved only on this iPhone.")
                }
            }
        }
        .screenBackground()
        .overlay {
            if viewModel.history.isEmpty && viewModel.submittedQuery == nil {
                ContentUnavailableView("Search for a medicine",
                                       systemImage: "pills",
                                       description: Text("Type a medicine name, e.g. Imatinib."))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.submittedQuery != nil {
                requestBar
            }
        }
        .navigationTitle("Find a medicine")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingScanner = true
                } label: {
                    Label("Scan box", systemImage: "text.viewfinder")
                }
            }
        }
        .sheet(isPresented: $showingScanner) {
            NavigationStack {
                ScanView(viewModel: services.makeScanViewModel()) { name, _ in
                    viewModel.query = name
                    viewModel.submit()          // searches straight away
                }
            }
        }
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Medicine name")
        .onSubmit(of: .search) { viewModel.submit() }
        .onChange(of: viewModel.query) { _, newValue in
            if newValue.isEmpty { viewModel.clearResult() }
        }
        .sheet(isPresented: $showingNewRequest) {
            NavigationStack {
                NewRequestView(viewModel: services.makeNewRequestViewModel(
                    medicineName: viewModel.submittedQuery ?? ""))
            }
        }
        .task { viewModel.loadHistory() }
        .refreshable { await viewModel.sources?.load() }
    }

    /// Coral bottom bar — the one main action on this screen.
    private var requestBar: some View {
        VStack(spacing: 6) {
            Button {
                showingNewRequest = true
            } label: {
                Label("Request this medicine", systemImage: "megaphone.fill")
            }
            .buttonStyle(.primaryPill)

            Text("Anonymous. Only your district is shared.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }
}