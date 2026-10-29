//
//  AppearancePicker.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  AppearancePicker.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI

/// Three preview tiles — System / Light / Dark — like iPhone Settings → Display.
struct AppearancePicker: View {
    @Binding var selection: AppearanceMode

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    withAnimation { selection = mode }
                } label: {
                    AppearanceTile(mode: mode, isSelected: selection == mode)
                }
                .buttonStyle(.plain)    // .plain = each button gets its own tap inside a List row
            }
        }
        .padding(.vertical, 6)
    }
}

/// One tile: a mini screen preview, the name, and a tick.
private struct AppearanceTile: View {
    let mode: AppearanceMode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            preview
                .frame(height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Theme.accent : Theme.ringTrack, lineWidth: isSelected ? 3 : 1)
                }

            Text(mode.title)
                .font(.subheadline.weight(.semibold))

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Theme.accent : Theme.tertiary)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(mode.title) appearance")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// The previews use FIXED colours on purpose: the "Dark" tile must look dark
    /// even while the app is in light mode (adaptive Theme colours would change).
    @ViewBuilder
    private var preview: some View {
        switch mode {
        case .light:
            MiniScreen(background: Color(hex: 0xF7F5F2), card: Color(hex: 0xFFFFFF))
        case .dark:
            MiniScreen(background: Color(hex: 0x0F1413), card: Color(hex: 0x1C2321))
        case .system:
            HStack(spacing: 0) {           // half light, half dark
                MiniScreen(background: Color(hex: 0xF7F5F2), card: Color(hex: 0xFFFFFF))
                MiniScreen(background: Color(hex: 0x0F1413), card: Color(hex: 0x1C2321))
            }
        }
    }
}

/// A tiny drawing of the app: teal hero strip + two cards.
private struct MiniScreen: View {
    let background: Color
    let card: Color

    var body: some View {
        ZStack(alignment: .top) {
            background
            VStack(spacing: 5) {
                Color(hex: 0x0E8C88).frame(height: 18)
                RoundedRectangle(cornerRadius: 4).fill(card).frame(height: 14).padding(.horizontal, 6)
                RoundedRectangle(cornerRadius: 4).fill(card).frame(height: 14).padding(.horizontal, 6)
            }
        }
    }
}

#Preview {
    @Previewable @State var mode = AppearanceMode.system
    List {
        Section("Appearance") { AppearancePicker(selection: $mode) }
    }
}
