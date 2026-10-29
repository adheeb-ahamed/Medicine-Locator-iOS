//
//  LevelRing.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Coral ring on the Profile hero: filled by progress to the next level, points in the middle.
/// Same two-circle idea as ConfidenceRing, but styled for the dark gradient.
struct LevelRing: View {
    let progress: Double      // 0.0–1.0
    let points: Int
    var size: CGFloat = 92

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: size * 0.11)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Theme.coral, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(points)")
                    .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                Text("points")
                    .font(.caption2.weight(.bold))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(points) reputation points, \(Int(progress * 100)) percent of the way to the next level")
    }
}