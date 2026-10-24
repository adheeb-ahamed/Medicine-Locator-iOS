//
//  CoreDataSourceCacheService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreData

/// Offline copy of ranked results, stored on the device with Core Data.
@MainActor
final class CoreDataSourceCacheService: SourceCacheServicing {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func save(_ sources: [ScoredResponse], for scopeKey: String) {
        // Replace whatever was saved for this screen before.
        deleteRows(matching: NSPredicate(format: "scopeKey == %@", scopeKey))

        let now = Date()
        for scored in sources {
            CachedSource(context: context)
                .update(from: SourceSnapshot(scored: scored, cachedAt: now), scopeKey: scopeKey)
        }
        try? context.save()
    }

    func load(for scopeKey: String) -> [SourceSnapshot] {
        let request = NSFetchRequest<CachedSource>(entityName: "CachedSource")
        request.predicate = NSPredicate(format: "scopeKey == %@", scopeKey)
        request.sortDescriptors = [NSSortDescriptor(key: "confidenceScore", ascending: false)]
        return ((try? context.fetch(request)) ?? []).compactMap(\.snapshot)
    }

    func clearAll() {
        deleteRows(matching: nil)
        try? context.save()
    }

    private func deleteRows(matching predicate: NSPredicate?) {
        let request = NSFetchRequest<CachedSource>(entityName: "CachedSource")
        request.predicate = predicate
        for row in (try? context.fetch(request)) ?? [] {
            context.delete(row)
        }
    }
}
