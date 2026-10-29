//
//  BottomBar.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Frosted bar for the main button at the bottom of a screen.
/// Use with .safeAreaInset(edge: .bottom) { BottomBar { … } }
struct BottomBar<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 6) {
            content
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }
}