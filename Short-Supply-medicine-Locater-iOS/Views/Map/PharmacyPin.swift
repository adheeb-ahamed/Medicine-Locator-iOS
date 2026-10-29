//
//  PharmacyPin.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Round map pin. Unselected: white circle with a coloured ring.
/// Selected: bigger, filled, with a soft pulsing halo.
struct PharmacyPin: View {
    let pharmacy: Pharmacy
    let isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion  // iPhone setting
    @AppStorage(AccessibilitySettings.reduceMotionKey) private var appReduceMotion = false  // our toggle

    /// True if either setting is on.
    private var reduceMotion: Bool {
        AccessibilitySettings.shouldReduceMotion(system: systemReduceMotion, app: appReduceMotion)
    }
    @State private var pulse = false

    private var color: Color { pharmacy.isVerified ? Theme.success : Theme.accent }
    private var fill: Color { pharmacy.isVerified ? Theme.successFill : Theme.accentFill }
    private var icon: String { pharmacy.kind == .hospital ? "cross.fill" : "pills.fill" }

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 68, height: 68)
                    .scaleEffect(pulse ? 1.15 : 0.85)
                    .opacity(pulse ? 0.35 : 0.8)
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
                    .onDisappear { pulse = false }
            }

            Image(systemName: icon)
                .font(.system(size: isSelected ? 18 : 13, weight: .bold))
                .foregroundStyle(isSelected ? .white : color)
                .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                .background(isSelected ? fill : Theme.card, in: Circle())
                .overlay(Circle().stroke(color, lineWidth: 3))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .animation(.spring(duration: 0.3), value: isSelected)
        // Read the pin as one item: "City Pharmacy, verified pharmacy"
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityText.pin(name: pharmacy.name,
                                                  isHospital: pharmacy.kind == .hospital,
                                                  isVerified: pharmacy.isVerified))
        // Tells VoiceOver it can be tapped, and whether it's the chosen one
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
