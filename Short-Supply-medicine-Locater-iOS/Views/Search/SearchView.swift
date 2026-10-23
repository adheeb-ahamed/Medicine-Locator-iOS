//
//  SearchView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// "Find a medicine" — search box + recent searches (stored on-device).
struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if let submitted = viewModel.submittedQuery {
                Section {
                    ContentUnavailableView {
                        Label("No reports for \(submitted) yet", systemImage: "magnifyingglass")
                    } description: {
                        Text("Soon you'll be able to ask people nearby to check licensed pharmacies for you.")
                    } actions: {
                        Button("Ask the community") {}
                            .disabled(true)          // enabled in Phase 5
                    }
                }
            }

            if !viewModel.history.isEmpty {
                Section {
                    ForEach(viewModel.history, id: \.self) { item in
                        Button {
                            viewModel.select(item)
                        } label: {
                            Label(item, systemImage: "clock.arrow.circlepath")
                        }
                        .foregroundStyle(.primary)
                    }
                    .onDelete { viewModel.delete(at: $0) }
                } header: {
                    HStack {
                        Text("Recent searches")
                        Spacer()
                        Button("Clear") { viewModel.clearHistory() }
                            .font(.caption)
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
        .task { viewModel.loadHistory() }
    }
}
