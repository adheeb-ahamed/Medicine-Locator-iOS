//
//  SourceListView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

//
//  SourceListView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// A List section of ranked reports, shown as cards. Used by Search and Request detail.
struct SourcesListView: View {
    let viewModel: SourcesViewModel          // owned by the parent screen
    let emptyMessage: String

    var body: some View {
        Section {
            if viewModel.isLoading && !viewModel.hasLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .cardRow()
            } else if viewModel.isOffline || !viewModel.cached.isEmpty {
                // Offline (or network failed): show saved results
                if viewModel.cached.isEmpty {
                    message("You're offline and nothing was saved for this yet.")
                }
                ForEach(viewModel.cached) { snapshot in
                    CachedSourceRow(snapshot: snapshot)
                        .cardRow()
                }
            } else {
                if viewModel.sources.isEmpty {
                    message(emptyMessage)
                }
                ForEach(viewModel.sources) { source in
                    NavigationLink {
                        SourceDetailView(source: source, pharmacy: viewModel.pharmacy(for: source))
                    } label: {
                        SourceRow(source: source)
                    }
                    .navigationLinkIndicatorVisibility(.hidden)   // the card has its own chevron
                    .cardRow()
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Theme.danger)
                    .cardRow()
            }
        } header: {
            Text("Where people have seen it")
                .font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(.primary)
                .textCase(nil)
        } footer: {
            Text("Confidence depends on who reported it, whether they were at the pharmacy, and how recent it is.")
        }
        .task(id: ObjectIdentifier(viewModel)) {
            await viewModel.load()
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .cardStyle()
            .cardRow()
    }
}
