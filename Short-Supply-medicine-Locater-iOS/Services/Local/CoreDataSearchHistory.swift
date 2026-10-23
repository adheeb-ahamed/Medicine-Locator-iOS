//
//  CoreDataSearchHistory.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreData

/// Search history stored in Core Data (on the device only — never uploaded).
@MainActor
final class CoreDataSearchHistoryService: SearchHistoryServicing {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func recentSearches() -> [String] {
        let request = NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
        request.sortDescriptors = [NSSortDescriptor(key: "searchedAt", ascending: false)]
        return ((try? context.fetch(request)) ?? []).compactMap(\.query)
    }

    func record(_ query: String) {
        SearchHistoryItem.record(query, in: context)   // the Phase 1 helper
    }

    func delete(_ query: String) {
        let request = NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
        request.predicate = NSPredicate(format: "query ==[c] %@", query)
        for item in (try? context.fetch(request)) ?? [] {
            context.delete(item)
        }
        try? context.save()
    }

    func clearAll() {
        let request = NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
        for item in (try? context.fetch(request)) ?? [] {
            context.delete(item)
        }
        try? context.save()
    }
}
