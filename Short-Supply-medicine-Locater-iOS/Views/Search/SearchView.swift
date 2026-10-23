//
//  SearchView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// "Find a medicine" — results ranked by trust, recent searches, and "Ask people nearby".
struct SearchView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var viewModel: SearchViewModel
    @State private var showingNewRequest = false

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if let submitted = viewModel.submittedQuery, let sources = viewModel.sources {
                SourcesListView(viewModel: sources,
                                emptyMessage: "No one has reported \(submitted) yet.")

                Section {
                    Button {
                        showingNewRequest = true
                    } label: {
                        Label("Ask people nearby to look for \(submitted)", systemImage: "megaphone")
                    }
                } footer: {
                    Text("Anonymous. Only your district is shared.")
                }
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
        .overlay {
            if viewModel.history.isEmpty && viewModel.submittedQuery == nil {
                ContentUnavailableView("Search for a medicine",
                                       systemImage: "pills",
                                       description: Text("Type a medicine name, e.g. Imatinib."))
            }
        }
        .navigationTitle("Find a medicine")
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
    }
}
