//
//  LevelJourneyView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  LevelJourneyView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// "Your journey" sheet: the level ladder + how to earn points.
/// Levels are a trust signal only — this screen says so, so it motivates without promising rewards.
struct LevelJourneyView: View {
    let reputation: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summary
                    ladder
                    earnCard

                    Text("Levels are a trust signal only — they don't unlock rewards and there are no leaderboards. Pharmacy and moderator roles come from verification, not points.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Your journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - "You have 0 points. 50 more to reach Helper."

    private var summary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("You have \(reputation) points")
                .font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            if let toNext = HelperLevel.pointsToNext(for: reputation),
               let next = HelperLevel(reputation: reputation).next {
                Text("\(toNext) more to reach \(next.title).")
                    .foregroundStyle(.secondary)
            } else {
                Text("You've reached the top level. Thank you!")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Ladder (top level first, like climbing up)

    private var ladder: some View {
        let levels = Array(HelperLevel.allCases.reversed())     // Champion … Newcomer
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(levels, id: \.self) { level in
                step(level, isLast: level == levels.last)
            }
        }
        .cardStyle()
    }

    /// One rung: round icon, line down to the next rung, title + points + meaning.
    private func step(_ level: HelperLevel, isLast: Bool) -> some View {
        let status = level.status(for: reputation)

        return HStack(alignment: .top, spacing: 14) {
            // Icon and the connecting line
            VStack(spacing: 0) {
                Image(systemName: status == .locked ? "lock.fill" : level.systemImage)
                    .font(.headline)
                    .foregroundStyle(status == .locked ? Theme.tertiary : .white)
                    .frame(width: 40, height: 40)
                    .background(circleColor(status), in: Circle())
                if !isLast {
                    Rectangle()                                    // the "rope" between rungs
                        .fill(status == .locked ? Theme.ringTrack : Theme.accent)
                        .frame(width: 3)
                        .frame(minHeight: 28)
                }
            }
            .accessibilityHidden(true)                             // decoration — the text says it all

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(level.title).font(.cardTitle)
                    if status == .current {
                        Text("You're here")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.coral)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.coralTint, in: Capsule())
                    }
                }
                Text(level.rawValue == 0 ? "Start" : "\(level.rawValue) points")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                Text(level.meaning)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
        .opacity(status == .locked ? 0.7 : 1)                      // locked levels look quieter
        // VoiceOver: "Helper, 50 points, your current level"
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(level.title), \(level.rawValue) points, \(spokenStatus(level, status))")
    }

    private func circleColor(_ status: HelperLevel.Status) -> Color {
        switch status {
        case .reached: Theme.accent      // teal = done
        case .current: Theme.coral       // coral = you are here
        case .locked:  Theme.ringTrack   // grey = still to climb
        }
    }

    private func spokenStatus(_ level: HelperLevel, _ status: HelperLevel.Status) -> String {
        switch status {
        case .reached: "reached"
        case .current: "your current level"
        case .locked:  "\(level.rawValue - reputation) points to go"
        }
    }

    // MARK: - How to earn points (built from the real rules)

    private var earnCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to earn points")
                .font(.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            // Same list as ReputationPolicy, so this screen can never disagree with the rules.
            ForEach(ReputationEvent.allCases, id: \.self) { event in
                HStack {
                    Text(event.label)
                        .font(.subheadline)
                    Spacer()
                    Text(event.points > 0 ? "+\(event.points)" : "\(event.points)")
                        .font(.system(.headline, design: .rounded, weight: .black))
                        .foregroundStyle(event.points > 0 ? Theme.success : Theme.danger)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .cardStyle()
    }
}

#Preview("60 points") {
    LevelJourneyView(reputation: 60)
}