//
//  SetupCheckView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import SwiftUI
import CoreData
import FirebaseCore

/// TEMPORARY: proves Firebase, the models and Core Data work. Deleted in Phase 2.
struct SetupCheckView: View {
    @Environment(\.managedObjectContext) private var context

    // A live query: the list updates by itself when Core Data changes.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SearchHistoryItem.searchedAt, ascending: false)],
        animation: .default
    )
    private var history: FetchedResults<SearchHistoryItem>

    @State private var query = ""

    private var firebaseApp: FirebaseApp? { FirebaseApp.app() }

    var body: some View {
        NavigationStack {
            List {
                // 1. Firebase
                Section("Firebase") {
                    LabeledContent("Configured") {
                        Image(systemName: firebaseApp == nil ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundStyle(firebaseApp == nil ? Theme.danger : Theme.success)
                    }
                    LabeledContent("Project", value: firebaseApp?.options.projectID ?? "—")
                }

                // 2. Models + component
                Section("Confidence levels") {
                    ForEach([0.85, 0.55, 0.25, 0.05], id: \.self) { score in
                        HStack {
                            Text(score, format: .percent)
                            Spacer()
                            ConfidenceBadge(level: ConfidenceLevel(score: score))
                        }
                    }
                }

                // 3. Core Data
                Section {
                    HStack {
                        TextField("Medicine name", text: $query)
                            .submitLabel(.search)
                            .onSubmit(save)
                        Button("Save", action: save)
                            .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if history.isEmpty {
                        Text("No searches yet").foregroundStyle(.secondary)
                    }

                    ForEach(history) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.query ?? "")
                            Text((item.searchedAt ?? .now).formatted(.relative(presentation: .named)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                } header: {
                    Text("Core Data — search history")
                } footer: {
                    Text("Testing to check if firebase is working and search")
                }
            }
            .navigationTitle("Setup check")
            .tint(Theme.accent)
        }
    }

    private func save() {
        SearchHistoryItem.record(query, in: context)
        query = ""
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { history[$0] }.forEach(context.delete)
        try? context.save()
    }
}

#Preview {
    SetupCheckView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
