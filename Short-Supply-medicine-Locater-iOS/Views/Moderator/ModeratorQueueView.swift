//
//  ModeratorQueueView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import SwiftUI

/// Moderator: pending pharmacy applications, oldest first.
struct ModeratorQueueView: View {
    @State private var viewModel: ModeratorViewModel

    init(viewModel: ModeratorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.queue) { application in
                NavigationLink {
                    ReviewView(application: application, viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(application.pharmacyName).font(.body.weight(.medium))
                        Text("\(application.contactName) · \(application.createdAt.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).font(.footnote).foregroundStyle(Theme.danger)
            }
        }
        .overlay {
            if viewModel.queue.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("Nothing to review",
                                       systemImage: "checkmark.seal",
                                       description: Text("New pharmacy applications appear here."))
            }
        }
        .screenBackground()
        .navigationTitle("Verification queue")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
