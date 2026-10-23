//
//  SearchViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation

/// "Find a medicine": search box, recent searches, and the sources for the submitted search.
@MainActor
@Observable
final class SearchViewModel {
    var query = ""
    private(set) var history: [String] = []
    private(set) var submittedQuery: String?
    private(set) var sources: SourcesViewModel?

    private let historyService: SearchHistoryServicing
    private let makeSources: @MainActor (String) -> SourcesViewModel

    init(historyService: SearchHistoryServicing,
         makeSources: @escaping @MainActor (String) -> SourcesViewModel) {
        self.historyService = historyService
        self.makeSources = makeSources
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func loadHistory() {
        history = historyService.recentSearches()
    }

    func submit() {
        guard !trimmedQuery.isEmpty else { return }
        historyService.record(trimmedQuery)
        submittedQuery = trimmedQuery
        sources = makeSources(Medicine.key(for: trimmedQuery))   // NEW
        loadHistory()
    }

    func select(_ item: String) {
        query = item
        submit()
    }

    func clearResult() {
        submittedQuery = nil
        sources = nil
    }

    func delete(at offsets: IndexSet) {
        for index in offsets { historyService.delete(history[index]) }
        loadHistory()
    }

    func clearHistory() {
        historyService.clearAll()
        loadHistory()
    }
}
