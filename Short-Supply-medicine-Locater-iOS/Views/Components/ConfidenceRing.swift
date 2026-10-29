//
//  ConfidenceRing.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Circular ring filled by the trust score, with the score in the centre.
/// Used on source cards, map pins, source detail, Home and Profile.
struct ConfidenceRing: View {
    let score: Double            // 0.0–1.0, straight from TrustScoreCalculator
    var size: CGFloat = 52
    var showsLevel = false       // show HIGH / MED / LOW under the number

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion  // iPhone setting
    @AppStorage(AccessibilitySettings.reduceMotionKey) private var appReduceMotion = false  // our toggle

    /// True if either setting is on.
    private var reduceMotion: Bool {
        AccessibilitySettings.shouldReduceMotion(system: systemReduceMotion, app: appReduceMotion)
    }
    /// Becomes bigger than 1 when the user picks bigger text.
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    /// Size actually drawn: base size × text scale, capped at 1.5× so it never gets huge.
    private var drawnSize: CGFloat { size * min(textScale, 1.5) }
    
    @State private var progress = 0.0   // what is drawn right now (animates up to score)

    private var level: ConfidenceLevel { ConfidenceLevel(score: score) }
    private var clamped: Double { min(max(score, 0), 1) }
    private var percent: Int { Int((clamped * 100).rounded()) }
    private var lineWidth: CGFloat { drawnSize * 0.12 }

    var body: some View {
        ZStack {
            // 1. Grey track = the full 100
            Circle()
                .stroke(Theme.ringTrack, lineWidth: lineWidth)

            // 2. Coloured arc = the score
            Circle()
                .trim(from: 0, to: progress)
                .stroke(level.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))          // start at 12 o'clock, not 3 o'clock

            // 3. Number (+ optional level) in the middle
            VStack(spacing: 0) {
                Text("\(percent)")
                    .font(.system(size: drawnSize * 0.32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                if showsLevel {
                    Text(level.shortLabel)
                        .font(.system(size: drawnSize * 0.14, weight: .heavy, design: .rounded))
                        .foregroundStyle(level.color)
                }
            }
        }
        .frame(width: drawnSize, height: drawnSize)
        .onAppear { fill() }
        .onChange(of: score) { fill() }
        // VoiceOver reads one sentence instead of "circle, circle, 82"
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityText.confidence(score: score))   // same sentence everywhere
    }

    /// Fill the ring with a short animation, unless the user turned on Reduce Motion.
    private func fill() {
        if reduceMotion {
            progress = clamped
        } else {
            withAnimation(.easeOut(duration: 0.8)) { progress = clamped }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ConfidenceRing(score: 0.86, showsLevel: true)
        ConfidenceRing(score: 0.55, showsLevel: true)
        ConfidenceRing(score: 0.22, showsLevel: true)
        ConfidenceRing(score: 0.86, size: 96, showsLevel: true)
    }
    .padding()
}
