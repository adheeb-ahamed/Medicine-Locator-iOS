//
//  PharmacyService.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-23.
//

import Foundation
import CoreData

enum PharmacyServiceError: LocalizedError {
    case seedFileMissing

    var errorDescription: String? {
        "The pharmacy list is missing from the app."
    }
}

/// Imports pharmacies.json into Core Data once, then always reads from Core Data.
@MainActor
final class PharmacyService: PharmacyServicing {
    /// Increase this whenever you edit pharmacies.json, so the new list is imported.
    static let seedVersion = 1
    private static let seedVersionKey = "pharmacySeedVersion"

    private let context: NSManagedObjectContext
    private let bundle: Bundle
    private let defaults: UserDefaults

    init(context: NSManagedObjectContext,
         bundle: Bundle = .main,
         defaults: UserDefaults = .standard) {
        self.context = context
        self.bundle = bundle
        self.defaults = defaults
    }

    func loadPharmacies() throws -> [Pharmacy] {
        try importSeedIfNeeded()
        return try fetchCached()
    }

    // MARK: - Private

    private func importSeedIfNeeded() throws {
        // Already imported this version? Skip.
        guard defaults.integer(forKey: Self.seedVersionKey) < Self.seedVersion else { return }

        guard let url = bundle.url(forResource: "pharmacies", withExtension: "json") else {
            throw PharmacyServiceError.seedFileMissing
        }

        // 1. Read and decode the JSON into [Pharmacy] (works because Pharmacy is Codable)
        let data = try Data(contentsOf: url)
        let pharmacies: [Pharmacy]
        do {
            pharmacies = try JSONDecoder().decode([Pharmacy].self, from: data)
        } catch {
            print("❌ pharmacies.json problem:", error)   // full details in Xcode's console
            throw error
        }

        // 2. Remove the old list
        let oldRequest = NSFetchRequest<CachedPharmacy>(entityName: "CachedPharmacy")
        for old in try context.fetch(oldRequest) {
            context.delete(old)
        }
        try context.save()

        // 3. Insert the new list
        for pharmacy in pharmacies {
            CachedPharmacy(context: context).update(from: pharmacy)
        }
        try context.save()

        defaults.set(Self.seedVersion, forKey: Self.seedVersionKey)
    }

    private func fetchCached() throws -> [Pharmacy] {
        let request = NSFetchRequest<CachedPharmacy>(entityName: "CachedPharmacy")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(request).compactMap(\.pharmacy)
    }
}
