//
//  CachedSource+Mapping.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation
import CoreData

extension CachedSource {

    /// Row ID = "<scope>|<responseID>", so the same report can be cached for a search AND a request.
    func update(from snapshot: SourceSnapshot, scopeKey: String) {
        id = "\(scopeKey)|\(snapshot.id)"
        self.scopeKey = scopeKey
        pharmacyID = snapshot.pharmacyID
        pharmacyName = snapshot.pharmacyName
        medicineName = snapshot.medicineName
        confidenceScore = snapshot.score
        wasOnSite = snapshot.wasOnSite
        expiresAt = snapshot.expiresAt
        cachedAt = snapshot.cachedAt
    }

    var snapshot: SourceSnapshot? {
        guard let id, let pharmacyName, let expiresAt, let cachedAt else { return nil }
        return SourceSnapshot(
            id: id.components(separatedBy: "|").last ?? id,
            pharmacyID: pharmacyID ?? "",
            pharmacyName: pharmacyName,
            medicineName: medicineName ?? "",
            score: confidenceScore,
            wasOnSite: wasOnSite,
            expiresAt: expiresAt,
            cachedAt: cachedAt
        )
    }
}
