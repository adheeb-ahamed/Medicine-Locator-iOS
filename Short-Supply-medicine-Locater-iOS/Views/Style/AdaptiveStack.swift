//
//  AdaptiveStack.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-30.
//


//
//  AdaptiveStack.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// HStack normally, VStack when the user picks one of the very large
/// accessibility text sizes (Settings → Accessibility → Larger Text).
struct AdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize   // the user's text size
    var spacing: CGFloat = 14
    @ViewBuilder var content: Content

    var body: some View {
        // AnyLayout lets us swap the layout without rebuilding the views inside,
        // so the change is smooth and nothing loses its state.
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))

        layout { content }
    }
}