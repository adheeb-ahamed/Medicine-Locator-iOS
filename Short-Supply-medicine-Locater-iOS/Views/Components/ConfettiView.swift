//
//  ConfettiView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Decorative confetti for success screens. Fixed positions (no randomness),
/// falls in once on appear, skipped animation with Reduce Motion, hidden from VoiceOver.
struct ConfettiView: View {
    private struct Piece {
        let x: CGFloat        // 0…1 across the width
        let y: CGFloat        // 0…1 down the height
        let color: Color
        let angle: Double
    }

    private let pieces: [Piece] = [
        Piece(x: 0.08, y: 0.18, color: Theme.coral,       angle: 20),
        Piece(x: 0.20, y: 0.42, color: .white,            angle: -35),
        Piece(x: 0.30, y: 0.12, color: Theme.warningTint, angle: 60),
        Piece(x: 0.42, y: 0.30, color: Theme.coralTint,   angle: -10),
        Piece(x: 0.55, y: 0.10, color: .white,            angle: 45),
        Piece(x: 0.66, y: 0.36, color: Theme.coral,       angle: -50),
        Piece(x: 0.78, y: 0.16, color: Theme.successTint, angle: 15),
        Piece(x: 0.90, y: 0.40, color: Theme.coralTint,   angle: -25),
        Piece(x: 0.14, y: 0.62, color: Theme.successTint, angle: 70),
        Piece(x: 0.86, y: 0.66, color: .white,            angle: -65)
    ]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dropped = false

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces.indices, id: \.self) { index in
                let piece = pieces[index]
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: 8, height: 14)
                    .rotationEffect(.degrees(piece.angle + (dropped ? 40 : 0)))
                    .position(x: geo.size.width * piece.x,
                              y: geo.size.height * piece.y + (dropped ? 0 : -60))
                    .opacity(dropped ? 1 : 0)
            }
        }
        .onAppear {
            if reduceMotion {
                dropped = true
            } else {
                withAnimation(.easeOut(duration: 1.0)) { dropped = true }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}