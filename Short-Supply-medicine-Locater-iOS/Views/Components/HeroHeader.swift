//
//  HeroHeader.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Teal gradient header with white title, faint texture circles and rounded bottom corners.
/// Anything extra (stat tiles, chips, avatars) is passed in as `content`.
struct HeroHeader<Content: View>: View {
    var eyebrow: String? = nil       // small text ABOVE the title ("Good morning")
    let title: String
    var subtitle: String? = nil      // text BELOW the title
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let eyebrow {
                Text(eyebrow)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Text(title)
                .font(.screenTitle)
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            content
                .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .background(alignment: .top) {
            // Fill the status-bar area above the hero with the gradient's top colour.
            // (.ignoresSafeArea can't reach there when the hero is inside a ScrollView.)
            Theme.heroTop
                .frame(height: 400)
                .offset(y: -400)          // sits directly ABOVE the hero, touching its top edge
                .accessibilityHidden(true)
        }
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(bottomLeadingRadius: Theme.Radius.hero,
                               bottomTrailingRadius: Theme.Radius.hero,
                               style: .continuous)
    }

    /// Gradient + two faint white circles for texture, clipped to the rounded shape.
    private var background: some View {
        ZStack(alignment: .topTrailing) {
            Theme.heroGradient
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 220, height: 220)
                .offset(x: 70, y: -60)
            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 120, height: 120)
                .offset(x: -140, y: 90)
        }
        .clipShape(shape)
        .ignoresSafeArea(edges: .top)     // gradient goes up behind the status bar
        .accessibilityHidden(true)        // decoration only
    }
}

/// Lets you write HeroHeader(title: "…") with no extra content.
extension HeroHeader where Content == EmptyView {
    init(eyebrow: String? = nil, title: String, subtitle: String? = nil) {
        self.init(eyebrow: eyebrow, title: title, subtitle: subtitle) { EmptyView() }
    }
}

#Preview {
    ScrollView {
        HeroHeader(eyebrow: "Good morning", title: "Find medicine") {
            HStack(spacing: 12) {
                StatTile(value: "12", label: "found nearby this week", systemImage: "checkmark.seal.fill")
                StatTile(value: "38", label: "helpers active today", systemImage: "person.2.fill")
            }
        }
    }
    .screenBackground()
}
