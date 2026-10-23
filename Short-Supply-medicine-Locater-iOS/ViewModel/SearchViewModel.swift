//
//  SearchViewModel.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import Observation

/// "Find a medicine": the search box and recent searches.
@MainActor
@Observable
final class SearchViewModel {
    var query = ""
    private(set) var history: [String] = []
    private(set) var submittedQuery: String?

    private let historyService: SearchHistoryServicing

    init(historyService: SearchHistoryServicing) {
        self.historyService = historyService
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
        loadHistory()
    }

    /// Tapping a recent search runs it again.
    func select(_ item: String) {
        query = item
        submit()
    }

    func clearResult() {
        submittedQuery = nil
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            historyService.delete(history[index])
        }
        loadHistory()
    }

    func clearHistory() {
        historyService.clearAll()
        loadHistory()
    }
}
