//
//  PersistenceController.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-22.
//

import CoreData

/// Sets up Core Data once and shares it across the app.d
struct PersistenceController {
    static let shared = PersistenceController()

    /// Memory-only store with sample data, for SwiftUI previews.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        for query in ["Imatinib 400 mg", "Tamoxifen 20 mg", "Insulin glargine"] {
            let item = SearchHistoryItem(context: context)
            item.query = query
            item.searchedAt = .now
        }
        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // MUST match the .xcdatamodeld file name.
        container = NSPersistentContainer(name: "MedicineLocator")

        if inMemory {
            // /dev/null = write nowhere, so nothing is saved to disk.
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        // Background saves show up in the UI automatically.
        container.viewContext.automaticallyMergesChangesFromParent = true
        // If a unique id clashes, the newest values win.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
