//
//  ScanParser.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
//

import Foundation

/// Turns raw text from a medicine box into a few likely medicine names.
enum ScanParser {

    /// Words printed on boxes that are never the medicine's name.
    static let ignoredWords: Set<String> = [
        "tablet", "tablets", "capsule", "capsules", "film", "coated", "film-coated",
        "injection", "syrup", "suspension", "solution", "oral", "for",
        "batch", "lot", "no", "exp", "expiry", "mfg", "mfd", "manufactured", "by",
        "rx", "only", "each", "contains", "store", "below", "keep", "out", "of",
        "reach", "children", "use", "dose", "usp", "bp", "ip", "pharmacy", "prescription"
    ]

    /// Matches strengths like "400 mg", "400mg", "0.5 mcg", "10 ml", "100 IU".
    static let strengthPattern = try! Regex(#"(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml|iu)\b"#).ignoresCase()

    static func suggestion(from lines: [RecognizedLine], barcodes: [String]) -> ScanSuggestion {
        // 1. Biggest text first — brand and generic names are printed largest.
        let bySize = lines.sorted { $0.height > $1.height }

        // 2. Clean each line and keep the ones that look like a name; no duplicates.
        var names: [String] = []
        var seenKeys: Set<String> = []
        for line in bySize {
            guard let name = cleanName(line.text) else { continue }
            let key = Medicine.key(for: name)
            if seenKeys.insert(key).inserted {
                names.append(name)
            }
        }

        return ScanSuggestion(names: Array(names.prefix(3)),
                              strength: lines.lazy.compactMap { strength(in: $0.text) }.first,
                              barcode: barcodes.first)
    }

    /// "Imatinib Tablets 400 mg" → "Imatinib". Returns nil if nothing name-like is left.
    static func cleanName(_ line: String) -> String? {
        // Remove the strength part
        let withoutStrength = line.replacing(strengthPattern, with: " ")

        // Remove packaging words
        let words = withoutStrength
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { word in
                let bare = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
                return !ignoredWords.contains(bare)
            }

        let text = words.joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))

        // Must be mostly letters, at least 3 of them, and not a whole sentence.
        let letters = text.filter(\.isLetter).count
        guard letters >= 3,
              text.count <= 30,
              Double(letters) / Double(text.count) >= 0.6 else { return nil }

        return text.capitalized
    }

    /// "400MG" → "400 mg"
    static func strength(in line: String) -> String? {
        guard let match = line.firstMatch(of: strengthPattern),
              let number = match.output[1].substring,
              let unit = match.output[2].substring else { return nil }
        return "\(number) \(unit.lowercased())"
    }
}
