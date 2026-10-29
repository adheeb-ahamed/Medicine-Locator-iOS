//
//  PillButtonStyle.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// The big 56-pt capsule button. Coral for the main action, teal for secondary.
struct PillButtonStyle: ButtonStyle {
    var color: Color = Theme.coral

    func makeBody(configuration: Configuration) -> some View {
        PillButton(configuration: configuration, color: color)
    }

    /// A small inner view so we can read `isEnabled` from the environment.
    private struct PillButton: View {
        let configuration: ButtonStyleConfiguration
        let color: Color
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.buttonLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: Theme.buttonHeight)
                .background(isEnabled ? color : Theme.tertiary, in: Capsule())
                .scaleEffect(configuration.isPressed ? 0.97 : 1)          // press feedback
                .animation(.spring(duration: 0.2), value: configuration.isPressed)
        }
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var primaryPill: PillButtonStyle { PillButtonStyle() }                     // coral
    static var tealPill: PillButtonStyle { PillButtonStyle(color: Theme.accentFill) }
}