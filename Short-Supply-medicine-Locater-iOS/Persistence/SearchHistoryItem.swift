//
//  SearchHistoryItem.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import CoreData

extension SearchHistoryItem {
    static let maxItems = 10

    /// Saves a search, moving repeats to the top and keeping only the newest 10.
    static func record(_ text: String, in context: NSManagedObjectContext) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        // 1. Already searched before? ([c] = case-insensitive)
        let request = NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
        request.predicate = NSPredicate(format: "query ==[c] %@", query)
        let existing = (try? context.fetch(request))?.first

        // 2. Reuse it or create a new one, then update the time.
        let item = existing ?? SearchHistoryItem(context: context)
        item.query = query
        item.searchedAt = .now
        try? context.save()

        // 3. Delete everything after the newest 10.
        let old = NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
        old.sortDescriptors = [NSSortDescriptor(key: "searchedAt", ascending: false)]
        old.fetchOffset = maxItems
        for item in (try? context.fetch(old)) ?? [] {
            context.delete(item)
        }
        try? context.save()
    }
}
