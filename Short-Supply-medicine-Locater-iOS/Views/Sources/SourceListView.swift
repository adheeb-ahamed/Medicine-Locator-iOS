//
//  SourceListView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import SwiftUI

/// A List section of ranked reports. Used by Search and Request detail.
struct SourcesListView: View {
    let viewModel: SourcesViewModel          // owned by the parent screen
    let emptyMessage: String

    var body: some View {
        Section {
            if viewModel.isLoading && !viewModel.hasLoaded {
                ProgressView()
            } else if viewModel.isOffline || !viewModel.cached.isEmpty {
                // Offline (or network failed): show saved results
                if viewModel.cached.isEmpty {
                    Text("You're offline and nothing was saved for this yet.")
                        .foregroundStyle(.secondary)
                }
                ForEach(viewModel.cached) { snapshot in
                    CachedSourceRow(snapshot: snapshot)
                }
            } else {
                if viewModel.sources.isEmpty {
                    Text(emptyMessage).foregroundStyle(.secondary)
                }
                ForEach(viewModel.sources) { source in
                    NavigationLink {
                        SourceDetailView(source: source, pharmacy: viewModel.pharmacy(for: source))
                    } label: {
                        SourceRow(source: source)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
            }
        }  header: {
            Text("Where people have seen it")
        } footer: {
            Text("Confidence depends on who reported it, whether they were at the pharmacy, and how recent it is.")
        }
        .task(id: ObjectIdentifier(viewModel)) {
            await viewModel.load()
        }
    }
}
